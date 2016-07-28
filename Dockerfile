FROM jruby:1.7.25-jre
COPY . .
RUN bundle
EXPOSE 8080
CMD rails server
