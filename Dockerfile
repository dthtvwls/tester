FROM jruby:1.7.25-jre
COPY Gemfile* ./
RUN bundle
COPY . .
EXPOSE 8080
CMD rails server
