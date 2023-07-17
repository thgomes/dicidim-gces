# Usa a imagem do Ruby 3.0.4 como base
FROM ruby:3.0.4

# Seta o diretorio de trabalho dentro do container
WORKDIR /app

# Instala dependencias do sistema
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  curl \
  git \
  libssl-dev \
  zlib1g-dev \
  libpq-dev

# Instala Node.js 16.18.1
RUN curl -fsSLO --compressed https://nodejs.org/dist/v16.18.1/node-v16.18.1-linux-x64.tar.xz \
    && tar -xJf node-v16.18.1-linux-x64.tar.xz -C /usr/local --strip-components=1 \
    && rm node-v16.18.1-linux-x64.tar.xz

# Instala Yarn
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null && \
  echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y yarn

# Instala Mailcatcher gem
RUN gem install mailcatcher --no-document

# Define variáveis de ambiente
ENV ALLOW_HOSTS=/.*/
ENV DATABASE_USERNAME=postgres
ENV DATABASE_PASSWORD=postgres
ENV DATABASE_HOST=postgres
ENV SMTP_ADDRESS=mailcatcher
ENV SMTP_PORT=1025
ENV REDIS_URL=redis://redis-queue:6379/1
ENV REDIS_CACHE_URL=redis://redis-cache:6380

# Copia arquivos do projeto para o container
COPY . /app

# Install dependencias do projeto
RUN bundle install
RUN npm install
RUN yarn

# Expoe portas
EXPOSE 3000 1080 1025

# Roda servido Rails
CMD ["rails", "server", "-b", "0.0.0.0"]
