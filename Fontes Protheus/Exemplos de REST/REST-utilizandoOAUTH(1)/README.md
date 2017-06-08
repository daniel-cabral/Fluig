# Usando OAuth para consumir API Publica:

Esse exemplo contém alguns javascripts que são necessários importar para o projeto na seguinte ordem:

> 1. hmac-sha1.js
> 1. hmac-sha256.js
> 1. enc-base64-min.js
> 1. oauth-1.0a.js
> 1. FluigAPI.js

### FluigAPI
 O FluigAPI foi uma implementação que criei para facilitar e abstrair o uso do OAuth nas chamadas do Fluig. Ela funciona da seguinte maneira:

1. **FluigAPI.setKeys(keysGET, keysPOST)**

 Essa função popula o objeto FluigAPI com as keys que são geradas através do provider e app OAuth. No dev explica como gerar essas keys.
No arquivo main.js tem um exemplo de como popular e mandar os parametros corretos para esse método.  

1. **FluigAPI.consume(type, urlApi, params, callbackSuccess, callbackError)**

 Essa função é a que consome um serviço da API do Fluig. Os parâmetros significam o seguinte:

> 1. **type**: 'GET' ou 'POST'
> 1. **urlApi**: A url da API que você quer usar
> 1. **params**: Os dados que devem ser enviados ao serviço, geralmente quando é POST
> 1. **callbackSuccess**: Aqui deve ser passado uma função que será executada se a requisição for concluída com sucesso. Essa função deve receber um parâmetro que é o retorno do serviço. Se não informado nada (ou null) vai simplesmente printar no console o retorno.
> 1. **callbackError**: Aqui deve ser passado uma função que será executada se a requisição der erro. Essa função deve receber um parâmetro que é o retorno do serviço. Se não informado nada (ou null) vai simplesmente printar no console o retorno.

No exemplo dentro desse projeto (main.js) é utilizado o FluigAPI.consume para consultar um dataset (colleague).