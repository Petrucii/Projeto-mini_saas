# Software as a Service Infrastructure - a mini version

| Campo  | Valor   |
|--------|---------|
| Data   | 08/2026 |
| Status | Aceito  |

## Responsáveis

- Gustavo Rodrigues de Oliveira - gustavo.2502290@aluno.impacta.edu.br
- Marcos Henrique Petruci - marcos.petruci@aluno.impacta.edu.br
- Ryan de Araujo Pimenta - ryan.araujo@aluno.impacta.edu.br
- Thiago Alves Soares - thiago.asoares@aluno.impacta.edu.br

## Contexto

Uma infraestrutura de SaaS condizente com uma demanda árdua. Aqui ela é simplificada, em uma versão mini.

## Decisão

Opta-se por Linux, virtualizado com o VMware Workstation 17.

Propõe-se uma integração com dois usos: acesso e manutenção, e estudo.

A máquina virtual inclui:

- Ubuntu Server 26.04 LTS
- MySQL 8.4.10
- Servidor Apache Tomcat
- Demais ferramentas de apoio, usadas em aula e por outros meios

### Credenciais

Usuários e senhas abaixo são de laboratório e **não têm segurança no momento**. Troque-os antes de qualquer uso fora da aula.

| Serviço         | Usuário | Senha |
|-----------------|---------|-------|
| Acesso à VM     | saas    | saas  |
| Servidor Tomcat | admin   | saas  |
| MySQL           | saas    | saas  |

O MySQL está liberado para acesso remoto, e essa configuração pode variar conforme o ambiente.

## Consequências

Quem utilizar esta infraestrutura pode migrá-la e dispô-la onde for necessário.

## Estrutura do repositório

- `database/schema.sql`: script MySQL com as tabelas do MVP do painel de chamados (estilo Kanban)
- `docs/modelagem.pdf`: escopo do MVP, diagrama de classes e script

## Banco de dados

Com o MySQL já instalado na VM, crie o schema com:

```bash
sudo mysql < database/schema.sql
```

O script exige MySQL 8.0 ou superior.
