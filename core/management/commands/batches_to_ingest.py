import urllib2, base64

import json
import logging

from dateutil import parser
from django.core.management.base import BaseCommand
from django.conf import settings

from chronam.core import models
from chronam.core.management.commands import configure_logging

configure_logging("batch_list_logging.config", "batch_list.log")
log = logging.getLogger(__name__)

class Command(BaseCommand):
    help = "Generates a list of batches to be ingested into chronam"

    def handle(self, **options):
        batches_from_transfer = get_batches_from_transfer()
        log.info(batches_from_transfer)


def get_batches_from_transfer():
    """
    This function will get all bags belonging to project ndnp from cts 

    It logs the list of batches to ingest in the log file batch_list.log
    This can be used to assist automate batch ingest on production in conjunction
    with load_batch management command. This command by itself * does not * ingest
    batches.
    """
    response_json = make_web_api_request(settings.TRANSFER_CHRONAM_PROJECT)
    # toss batches that are already ingested/in the db
    batches = filter_existing_batches(response_json) 
    batches = filter(lambda b: 'sample' not in b['id'].lower(), batches)
    best_copies = map(get_best_copy_instance_for_bag, batches)
    return post_process_batch_list(best_copies)

def get_best_copy_instance_for_bag(bag_json):
    links = bag_json['links'] 
    filepath, accept_date = None, None
    if links:
        bag_instance_link = filter(lambda l: l['rel'] == 'bag_instances', links)
        if bag_instance_link:
            bag_instance_request_url = bag_instance_link[0]['href']
            if bag_instance_request_url:
                response_json = make_web_api_request(bag_instance_request_url)
                all_bag_instances = []
                for bag_instance in response_json:
                    if bag_instance['bagInstanceTypes'] and \
                       bag_instance['bagInstanceTypes'][0]['name'] == 'public access' and \
                       bag_instance['storageSystem']['id'] == 'ndn03blp':
                        all_bag_instances.append(bag_instance['filepath'])
                if all_bag_instances:
                    filepath = all_bag_instances[0]
                # if there are multiple public instances, pick highest version
                if len(all_bag_instances) > 1: 
                    for path in all_bag_instances[1:]:
                        if int(path[-1]) > int(filepath[-1]):
                            filepath = path

        events_link = filter(lambda l: l['rel'] == 'events', links)
        if filepath and events_link:
            events_request_url = events_link[0]['href']
            if events_request_url:
                response_json = make_web_api_request(events_request_url)
                accept_event = filter(lambda e: e['type'] == 'BagAcceptedEvent', 
                                       response_json)
                if accept_event:
                    accept_date = parser.parse(accept_event[0]['updateTimestamp'])
    return filepath, accept_date

def make_web_api_request(request_url):
    """
    makes a web api request to transfer web api and returnds jsonified response
    """
    request = urllib2.Request('%s%s' % (settings.TRANSFER_WEB_API_URL, request_url), 
                              headers={"Accept" : "application/json"})
    base64string = base64.encodestring('%s:%s' % (settings.TRANSFER_WEB_API_USER,
                                                  settings.TRANSFER_WEB_API_PASSWORD)
                                                 ).replace('\n', '')
    request.add_header("Authorization", "Basic %s" % base64string)
    response = urllib2.urlopen(request)
    response_content = response.readlines()[0]
    return json.loads(response_content)

def post_process_batch_list(batch_list):
    return [b for b in batch_list if b[0] is not None and b[1] is not None]


def filter_existing_batches(batch_list):
    batches = []
    for batch in batch_list:
        id = batch['id']
        request_url = filter(lambda l: l['rel'] == 'self', 
                             batch['links'])[0]['href']
        batch_json = make_web_api_request(request_url)
        if not models.Batch.objects.filter(
                                    name='%s_ver0%s' % (id, batch_json.get('currentBagVersion', 
                                                              batch_json.get('bagVersion', None)))
                                    ).count():
            batches.append(batch)
    return batches
