# Payment API

API de Processamento de Transações de Pagamento com Parcelamento e Liquidação, desenvolvida em **Ruby on Rails**.  
Este projeto visa a contemplação de um desafio técnico.

---

## Descrição

Esta aplicação **simula** o processamento de transações de pagamento:

- **Criação de transações**: com valor total, número de parcelas e método de pagamento.
- **Aprovação/Reprovação**: regra simples de “parcelas ímpares => reprovado, parcelas pares => aprovado”.
- **Retenção por parcela**: calculada via uma tabela de taxas (`installment_fees`).
- **Criação de Recebíveis**: para transações aprovadas, o valor líquido é dividido em parcelas.
- **Liquidação de Recebíveis**: via job diário (**sidekiq-scheduler**), marcando as parcelas cujo `schedule_date` é hoje como “liquidadas”.

---

## Requisitos

- **Ruby** 3.1.2
- **Rails** 7.2
- **PostgreSQL**
- **Redis** 
- **Docker** 

---

## Instalação e Setup

### Rodando com Docker

1. **Clone** o repositório:
   ```bash
   git clone https://github.com/SEU_USUARIO/payment_api.git
   cd payment_api
   ```

2. **Suba os containers**:
   ```bash 
   docker-compose up -d --build
   ```

3. **Execute as migrations**  
   Entre no container `payment_api_web` via Docker Desktop ou linha de comando e rode:
   ```bash
   rails db:create
   rails db:migrate
   rails data:migrate
   ```

4. **Configuração do Banco de Dados**  
   O projeto já possui um banco configurado, mas você pode editar `config/database.yml` para usar um próprio.

---

## Testes

### RSpec

Os testes são escritos com **RSpec**. Para rodar os testes dentro do container `payment_api_web`, execute:

```bash
bundle exec rspec
```

---

## Painel Sidekiq

O painel do Sidekiq pode ser acessado em:

[http://localhost:3000/sidekiq](http://localhost:3000/sidekiq)

---

## Endpoints Principais

### 1. Criar Transação

**POST** `/payment_transactions`

**Exemplo de Request**:
```json
{
  "transaction": {
    "amount": 1000.0,
    "installment": 10,
    "payment_method": "visa"
  }
}
```

- **Regra**: Parcelas pares → aprovado, ímpares → reprovado.
- **Retenção**: 0,99% por parcela ou mais (tabela `installment_fees`).

**Exemplo de Resposta**:
```json
{
  "transaction_id": 123,
  "status": "aprovado",
  "message": "Transação aprovada e em processamento."
}
```

---

### 2. Listar Transações

**GET** `/payment_transactions`

- **Filtros**: `start_date`, `end_date` (padrão últimos 30 dias), `page`, `per_page`.

**Exemplo de Resposta**:
```json
[
  {
    "id": 1,
    "installment": 10,
    "status": "aprovado"
  },
  ...
]
```

---

### 3. Listar Recebíveis

**GET** `/receivables`

- **Possível filtro**: `approved_only=true` para exibir apenas recebíveis ligados a transações aprovadas.

**Exemplo de Resposta**:
```json
[
  {
    "transaction_id": 123,
    "installment": 1,
    "schedule_date": "2025-03-10",
    "liquidation_date": null,
    "status": "pendente",
    "amount_to_settle": 90.10,
    "amount_settled": 0.0
  },
  ...
]
```

---

## Liquidação de Recebíveis (Cron)

Um job (via **sidekiq-scheduler**) liquida os recebíveis cujo `schedule_date` é **hoje**, marcando:

- **status** = `"liquidado"`
- **liquidation_date** = `data atual`

### Exemplo de configuração no `config/sidekiq.yml`:
```yaml
:scheduler:
  :schedule:
    receivable_liquidation:
      cron: "0 0 * * *"
      class: ReceivableLiquidationWorker
      queue: receivable_liquidation
```
