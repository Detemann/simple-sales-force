# 📱 Aplicativo de Força de Vendas

Aplicativo mobile para gerenciamento de força de vendas com cadastros de usuários, clientes e produtos.

## ✨ Funcionalidades

### 🔐 Autenticação
- Tela de login com validação
- Usuário admin padrão (`admin`/`admin`)
- Cadastro de novos usuários

### 📝 Cadastros CRUD
| Entidade  | Operações | Campos Obrigatórios |
|-----------|-----------|---------------------|
| 👥 Usuários | Create/Read/Update/Delete | ID, Nome, Senha |
| 🏢 Clientes | Create/Read/Update/Delete | ID, Nome, Tipo, CPF/CNPJ |
| 🛍️ Produtos | Create/Read/Update/Delete | ID, Nome, Unidade, Estoque, Preço, Status |

### 💾 Persistência
- Armazenamento em arquivos JSON
- Validação de campos obrigatórios (*)

## 🚀 Como Executar

```bash
# Clone o repositório 
# Abra no Android Studio
# Conecte um dispositivo ou emulador
# Execute o aplicativo
