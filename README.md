# XUI.one 1.5.13 — Auto-Installer Standalone

Instalador automatizado e 100% independente do **XUI.one v1.5.13**, configurado sem dependências de servidores ou repositórios externos de terceiros.

---

## 🚀 Compatibilidade

- ✅ **Ubuntu 20.04 LTS** (x86_64)
- ✅ **Ubuntu 22.04 LTS** (x86_64)
- ✅ **Ubuntu 24.04 LTS** (x86_64)
- ✅ **Debian 11 / 12** (x86_64)

> [!NOTE]
> Recomenda-se executar em um servidor limpo (instalação recente).

---

## 📦 Como Instalar

Execute os comandos abaixo como `root`:

```bash
apt-get update && apt-get install -y git
git clone https://github.com/lukinhanw/x-1513.git
cd x-1513
chmod +x install.sh
./install.sh
```

---

## ⚙️ Características e Melhorias

1. **Zero Dependência Externa:**
   - Todos os scripts (`install.sh`, `install.python3`, `build-php.sh`), patches e arquivos de ativação estão contidos dentro deste repositório.
   - Não depende do repositório `PabloServers` ou de links legados do `amidevous`.

2. **PHP 7.4 com Suporte Nativo a OpenSSL 3.0:**
   - O instalador inclui o patch `0060-Add-minimal-OpenSSL-3.0-patch.patch` e compila o PHP 7.4.33 diretamente no servidor com compatibilidade para distribuições modernas (Ubuntu 22.04 e 24.04).

3. **Hospedagem Própria dos Arquivos Pesados:**
   - O pacote principal `XUI_1.5.13.zip` é servido diretamente pelo seu próprio servidor em `http://208.87.243.165/downloads/XUI_1.5.13.zip` com fallback para as Releases deste repositório.
   - Caso queira utilizar um link personalizado para baixar o `.zip`, defina a variável `XUI_URL`:
     ```bash
     XUI_URL="http://seu-servidor/XUI_1.5.13.zip" ./install.sh
     ```

4. **Credenciais e Painel:**
   - Ao término da instalação, as credenciais do banco de dados MySQL e o endereço completo de acesso ao painel de administração serão exibidos no terminal e salvos em `credentials.txt`.
