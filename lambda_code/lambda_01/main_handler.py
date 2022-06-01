import json, logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f'event: {event}')
    
    ##########################
    return {
        'statusCode': 200,
        'body': json.dumps('This is Lambda 01'),
        'moreInfo': {
            'Lambda Request ID': '{}'.format(context.aws_request_id)
            }
        }