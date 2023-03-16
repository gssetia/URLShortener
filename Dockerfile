FROM python:latest

WORKDIR /application

ADD application /application

RUN pip install --trusted-host pypi.python.org -r requirements.txt

EXPOSE 80

CMD ["python3", "urlshortener.py"]
