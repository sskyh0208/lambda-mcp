import boto3
import os

TAG_KEY = os.environ.get('TARGET_TAG_KEY', 'MCP-Managed')
TAG_VALUE = os.environ.get('TARGET_TAG_VALUE', 'lambda-bastion-ec2-controller')

def lambda_handler(event: dict, context: dict) -> dict:
    """
    踏み台EC2サーバーを起動または停止する
    
    プロンプト例:
    「踏み台サーバーを起動して」
    「踏み台サーバーを停止して」
    """
    # 'action' パラメータを取得
    action = event.get('action')

    # 'action' が 'start' または 'stop' でない場合、エラーを返す
    if action not in ['start', 'stop']:
        return {'error': 'action は start または stop である必要があります'}
    
    # EC2クライアントを作成
    ec2 = boto3.client('ec2')
    filters = [
        {'Name': f'tag:{TAG_KEY}', 'Values': [TAG_VALUE]},
        {'Name': 'instance-state-name', 'Values': ['stopped' if action == 'start' else 'running']}
    ]

    try:
        # フィルタに基づいてインスタンスを取得
        instances = ec2.describe_instances(Filters=filters)
        instance_ids = [instance['InstanceId'] for reservation in instances['Reservations'] for instance in reservation['Instances']]
        
        # インスタンスが見つからない場合のメッセージを返す
        if not instance_ids:
            return {'message': f'{"停止中"if action == "start" else "起動中"}のインスタンスが見つかりません'}
        
        # 指定されたアクションを実行
        if action == 'start':
            ec2.start_instances(InstanceIds=instance_ids)
            return {'message': f'インスタンスを起動しました: {instance_ids}'}
        elif action == 'stop':
            ec2.stop_instances(InstanceIds=instance_ids)
            return {'message': f'インスタンスを停止しました: {instance_ids}'}

    except Exception as e:
        # エラーが発生した場合、エラーメッセージを返す
        return {'error': str(e)}