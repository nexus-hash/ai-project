FROM tensorflow/tensorflow:2.2.0rc3
COPY . /app
WORKDIR /app

RUN ls
RUN ls ./app

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN chmod +x /app
#EXPOSE 5000

ENTRYPOINT ["python"]
CMD ["run.py"]