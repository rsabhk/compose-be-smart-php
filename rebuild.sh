docker build . --build-arg DOC_ROOT=sources -t app/be-smart-php:staging &&
docker tag app/be-smart-php:staging registry1.rsabhk.co.id:5080/rsabhk/be-smart-php:staging &&
docker push registry1.rsabhk.co.id:5080/rsabhk/be-smart-php:staging