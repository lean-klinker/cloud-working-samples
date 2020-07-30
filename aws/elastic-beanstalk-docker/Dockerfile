FROM python:3.8

RUN pip install pipenv

COPY . /app

WORKDIR /app

RUN pipenv lock --requirements > requirements.txt

RUN pip install -r requirements.txt

ENV PORT 3000
EXPOSE 3000

CMD ["python", "app.py"]

