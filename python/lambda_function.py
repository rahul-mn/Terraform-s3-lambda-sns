import urllib.parse
import boto3

print('Loading function')

#defining the client as S3
s3 = boto3.client('s3')


def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))
    # Get the object from the event and show its content type
    
    #Grab the bucket name from event message and store in var bucket
    bucket = event['Records'][0]['s3']['bucket']['name']
    
    #Grab the Object key(filename with extension) from the event msg and convert the ASCII into utf-8
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        #Store the metadata of var(key) on var(response)
        response = s3.get_object(Bucket=bucket, Key=key)
        #From the metadata, print the ContentType of the object 
        print("CONTENT TYPE: " + response['ContentType'])
        #return the output with object name 
        return "object {} have been uploaded successfully.".format(key)
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e