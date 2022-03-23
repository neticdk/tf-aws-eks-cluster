apiVersion: v1
kind: Config
preferences: {}
current-context: aws

clusters:
- cluster:
    server: ${server}
    certificate-authority-data: ${certificate_authority_data}
  name: kubernetes

contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws

users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${cluster_name}"
        - "-r"
        - "${aws_role}"
      env:
        - name: AWS_PROFILE
          value: ${aws_profile}
