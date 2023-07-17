# Configurando ambiente

## Subindo o ambiente pela primeira vez (Baby steps)

Para subir o ambiente corretamente, é necessário que se tenha as seguintes ferramentas (sim, a versão importa):

* Git - versão 2.34 ou superior
* Ruby - versão 3.0.4
* NodeJS - versão 16.18.x
* NPM - versão 8.19.x
* Docker
* Docker Compose

> Esse guia foi primariamente feito para Ubuntu, especificamente Ubuntu 22.04 LTS. Versões diferentes ou SOs diferentes podem variar em alguns passos.

### Instalando o Ruby

Para instalar o Ruby, é recomendado que se utilize de uma ferramenta de gerenciamento de versões de Ruby. Para este guia, se utilizará o _rbenv_.

#### Instalando o rbenv

```bash
sudo apt update
```

```bash
sudo apt install -y build-essential curl git libssl-dev zlib1g-dev
```

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```

```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
```

```bash
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
```

```bash
source ~/.bashrc
```

```bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

#### Instalando o _ruby_

```bash
rbenv install 3.0.4 -v
```

```bash
rbenv global 3.0.4
```

### Instalando o Node

É necessario instalar o _node_ na versão 16.18.x no projeto. Você pode estar utilizando um gerenciador de versões como o [NVM](https://www.freecodecamp.org/news/node-version-manager-nvm-install-guide/), ou pode estar utilizando o _apt-get_ rodando os comandos abaixo:

> Caso você tenha problemas com a instalação de componentes no Ubuntu com o _apt-get_, abra o _"Software & Updates"_, e na aba _"Ubuntu Software"_, mude a opção _download from_ de **Brazil** para **Main Server**.

```bash
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
```

```bash
sudo apt-get install -y nodejs
```

```bash
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
```

```bash
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
```

```bash
sudo apt-get update && sudo apt-get install -y yarn
```

### Instalando o Docker e o Docker Compose

* Para instalar o Docker, recomenda-se seguir o tutorial oficial disponível [aqui](https://docs.docker.com/engine/install/ubuntu/).
* Após instalar o Docker, também é recomendado seguir os passos pós-instalação disponíveis [aqui](https://docs.docker.com/engine/install/linux-postinstall/).
* Feita a instalação do Docker e as configurações pós-instalação, instale o plugin _compose_ seguindo o tutorial oficial disponível [aqui](https://docs.docker.com/compose/install/linux/).

### Instalando o pacote de desenvolvimento PostgreSQL

Para rodar o projeto, é necessário que se tenha o pacote de desenvolvimento do _Postgres_ instalado na máquina local (mesmo que o banco esteja _dockerizado_). Para executar a instalação desse pacote, utilize o comando:

```bash
sudo apt install libpq-dev
``` 

### Clonando o repositório

Clone o repositório através do comando (via HTTPS)

```bash
git clone https://gitlab.com/lappis-unb/decidimbr/decidim-govbr.git
```

### Fixando a versão Ruby

> Neste e nos próximos passos, os comandos são executados estando dentro da pasta do projeto!

Como apresentado anteriormente, o projeto necessita do Ruby na versão 3.0.2. Para fixar esta versão para o projeto, use o comando

```bash
rbenv local 3.0.4
```

> Este comando criará um arquivo `.ruby-version`, caso ainda não exista, contendo a versão do ruby utilizada no projeto.

### Instalando as dependencias do projeto

Primeiramente, é necessário instalar as _gems_ utilizadas no projeto através do comando

```bash
bundle install
```

Em seguida, é necessário rodar o NPM e o YARN

```bash
npm install
```

```bash
yarn
```

### Instalando o `mailcatcher`

Uma ferramenta importante na configuração inicial do ambiente é o _mailcatcher_. O mailcatcher é uma _gem_ Ruby que simula um servidor _smtp_ e pode estar sendo utilizada para interceptação de e-mails enviados no ambiente de desenvolvimento.

Para instalar o mailcatcher, utilize o comando

```bash
gem install mailcatcher --no-document
```

### Levantando os Containers

O projeto necessita de 3 containers, a saber: Postgres, Redis para cache e Redis para filas.
Para subir os containers utilize o comando

```bash
docker compose up -d
```

### Criando a base de dados

O próximo passo é criar a base de dados dentro do _Postgres_ (certifique-se de que o container do _postgres_ está rodando analisando a saída do comando `docker ps`).

1. Crie um arquivo `.env`
2. Dentro desse arquivo, coloque o seguinte conteúdo
```.env
ALLOW_HOSTS=/.*/
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
```
3. Rode o comando
```bash
rails db:create db:migrate
```

### Criando um usuário admin

Para o primeiro acesso, é necessário criar um usuário admin. Para criá-lo, abra o rails console

```bash
rails c
```

Crie um novo usuário admin substituindo `<email>` por um e-mail de sua preferencia, `<password>` por uma senha de sua preferencia.

```ruby
Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>).save!(validate: false)
```

Feche o rails console digitando `exit` ou pressionando CTRL+D

### Subindo servidor local

Para subir o servidor local, rode o comando

```bash
rails server
```

Quando aparecer a mensagem `Listening on http://127.0.0.1:3000` acesse em seu navegador o endereço `localhost:3000/system`.

> Note que na primeira vez que for acessada a página da aplicação, os assets (javascripts, css, imagens, etc.) serão compilados pelo _Webpacker_, algo que pode levar algum tempo. Caso ocorra algum erro nessa etapa, verifique se o node está na versão exigida para o projeto. Verifique também se foram rodados corretamente os comandos `npm install` e `yarn` antes de subir a aplicação.

### Subindo o Sidekiq e o Mailcatcher

Duas ferramentas serão necessárias durante a utilização do ambiente de desenvolvimento: o _sidekiq_ e o _mailcatcher_. O _sidekiq_ é uma _gem_ _ruby_ que fornece um mecanismo de processamento de _jobs_ ou _tarefas_ em segundo plano.

---
Suba o mailcatcher com o comando
```
mailcatcher
```
Em seguida, suba o sidekiq com o comando:
```bash
bundle exec sidekiq
```

### Acessando a aplicação

Depois de acessar a URL `localhost:3000/system`, aparecerá na tela uma área de login. Forneça a senha e o e-mail utilizado na criação do usuário _admin_.

### Preenchendo cadastro inicial de organização

No primeiro _login_ você será direcionado para uma página para criar a primeira organização dentro da aplicação.

* No campo _Name_ preencha o nome da organização que você deseja criar. Por exemplo: `Organization 1`
* No campo _Reference prefix_ preencha o prefixo de identificacao da organização em minúsculo. Por exemplo `org1`
* No campo _Host_ preencha com o domínio que será utilizado na URL da organização. Nesse caso, preencha com `localhost`
* No campo _Secondary host_ não é necessário preencher nada.
* No campo _Organization admin name_ preencha o nome do administrador da organização. Por exemplo: `Decidim Admin`
* No campo _Organization admin email_  preencha o e-mail que será utilizado pelo administrador da organização. Por exemplo: `admin@example.com`
* Na seção _Organization locales_  selecione quais os idiomas estarão habilitados na organização, e a linguagem padrão. Por exemplo: `enabled: English, Português`, `default: Português`
* No campo _User registration mode_ selecione a opção `allow participants to register and login`
* Na seção _available authorizations_ selecione todos as opções.

Clique em `Create organization & invite admin`

### Acessando a organização com _admin_

Depois de finalizar o cadastro da organização, abra o _mailcatcher_ no navegador acessando o endereço `http://127.0.0.1:1080`. Clique no e-mail enviado, e no conteúdo do e-mail clique em `Aceitar convite`.

---

Ao clicar na confirmação do e-mail, será aberta uma página para finalizar a criação do admin da organização.

* Preencha o _nickname_ com o apelido do administrador da organização. Por exemplo: `admin`
* Preencha os campos de senha com uma senha forte. Por exemplo: `dBzJR2TVF4Ns&Wf&VashYqU#gG8^TC!B4sb$BiNS` <small>(Não discuta, apenas copie e cole essa senha :clown:)</small>
* Marque os check-boxes e depois clique em `Salvar`
* No modal amarelo que aparece na tela, clique em `Reveja-os agora`.
* Em seguida clique em `I agree with the terms`

---

**Parabéns você chegou ao fim da instalação :rocket:**
