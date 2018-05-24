FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y libmysqlclient-dev
RUN apt-get install -y git
RUN pip3 install --upgrade pip

COPY zoya zoya/

RUN pip3 install -r zoya/requirements.txt

ENV FLASK_APP=zoya/zoya.py
ENV FLASK_ENV=development
ENV GIT_PYTHON_REFRESH=quiet
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
CMD ["flask", "run", "--host=0.0.0.0", "--port=80"]

EXPOSE 80
