FROM quay.io/helmpack/chart-testing:v3.11.0

RUN helm_unittest_version=0.8.2 \
    && helm plugin install https://github.com/helm-unittest/helm-unittest.git --version ${helm_unittest_version} \
    && helm plugin list

RUN kubeconform_version=0.7.0 \
    && wget -O kubeconform.tgz https://github.com/yannh/kubeconform/releases/download/v${kubeconform_version}/kubeconform-linux-amd64.tar.gz \
    && tar xvf kubeconform.tgz \
    && mv ./kubeconform /usr/local/bin \
    && kubeconform -v

WORKDIR /src
