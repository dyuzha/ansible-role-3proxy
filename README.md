# 3proxy — Ansible-роль

Ansible-роль устанавливает и настраивает прокси-сервер 3proxy с поддержкой HTTP и SOCKS-прокси на Debian и Ubuntu.

[![Lint](https://github.com/dyuzha/ansible-role-3proxy/actions/workflows/lint.yml/badge.svg)](https://github.com/dyuzha/ansible-role-3proxy/actions/workflows/lint.yml)

## Возможности

- установка 3proxy из исходного архива;
- проверка контрольной суммы исходного архива;
- настройка HTTP- и SOCKS-портов;
- настройка DNS-серверов;
- настройка клиентов прокси и паролей;
- установка и управление systemd-сервисом;
- необязательная настройка правил UFW.

## Требования

- Debian Bookworm или Trixie;
- Ubuntu Focal или Jammy;
- Ansible версии 2.8 или новее;
- права `become: true` на целевых хостах;
- доступ к интернету на целевых хостах;
- коллекция `community.general`.

Роль устанавливает пакет `build-essential` и при включённом `proxy3_use_ufw` — пакет `ufw`.

## Установка

### Из Ansible Galaxy

После публикации роли в Ansible Galaxy установите её через файл зависимостей, например `roles/requirements.yml`:

```yaml
---
roles:
  - name: dyuzha.proxy3
```

```bash
ansible-galaxy role install -r roles/requirements.yml
```

### Непосредственно из GitHub

До публикации в Galaxy или для фиксации конкретной ветки/версии используйте GitHub-репозиторий:

```yaml
---
roles:
  - name: dyuzha.proxy3
    src: https://github.com/dyuzha/ansible-role-3proxy.git
    scm: git
    version: main
```

Коллекция `community.general` нужна в обоих вариантах. Установите её отдельно:

```bash
ansible-galaxy collection install community.general
```

Файл `requirements.yml` в репозитории содержит зависимости самой роли — коллекции Ansible. Файл `roles/requirements.yml` в пользовательском проекте содержит роли из Galaxy или GitHub.

Если роль подключается из локального репозитория, отдельная установка не нужна.

## Использование

### Минимальный пример

```yaml
- name: Configure proxy servers
  hosts: proxy
  become: true
  roles:
    - role: dyuzha.proxy3
```

### Пример с настройками

```yaml
- name: Configure proxy servers
  hosts: proxy
  become: true
  vars:
    proxy3_http_port: 3128
    proxy3_socks_port: 1080
    proxy3_dns:
      - 1.1.1.1
      - 1.0.0.1
    proxy3_use_ufw: true
    proxy3_clients:
      - name: client0
        password: "{{ vault_proxy3_client0_password }}"
  roles:
    - role: dyuzha.proxy3
```

Пароли клиентов не следует хранить в открытом виде. Разместите их в зашифрованных переменных Ansible Vault, например в `group_vars/<группа>/vault.yml`.

Если `proxy3_clients` пуст или не определён, подключения принимаются без проверки имени пользователя и пароля. Непустой список включает авторизацию клиентов.

## Переменные

| Переменная | Тип | По умолчанию | Описание |
|---|---|---:|---|
| `proxy3_version` | string | `0.9.5` | Версия исходного архива 3proxy. |
| `proxy3_sources_checksum` | string | SHA-256 | Контрольная сумма архива; должна соответствовать `proxy3_version`. |
| `proxy3_http_port` | integer | `3128` | Порт HTTP-прокси. |
| `proxy3_socks_port` | integer | `1080` | Порт SOCKS-прокси. |
| `proxy3_system_group_id` | integer | `200` | GID системной группы `proxy3`. Не должен конфликтовать с существующей группой. |
| `proxy3_system_user_id` | integer | `201` | UID системного пользователя `proxy3`. Не должен конфликтовать с существующим пользователем. |
| `proxy3_dns` | list[string] | `1.1.1.1`, `1.0.0.1` | DNS-серверы для разрешения имён. |
| `proxy3_use_ufw` | boolean | `false` | Устанавливать и настраивать UFW. При `false` firewall нужно настроить отдельно. |
| `proxy3_build_essential_version` | string | `latest` | Версия пакета `build-essential`, устанавливаемого через APT. |
| `proxy3_clients` | list[object] | — | Клиенты прокси. Пустой список означает отсутствие проверки авторизации. |

Элемент `proxy3_clients` имеет следующий формат:

```yaml
proxy3_clients:
  - name: client0
    password: "{{ vault_proxy3_client0_password }}"
```

## Теги

Роль предоставляет теги стадий:

- `install` — создание пользователя и группы, загрузка и компиляция 3proxy;
- `config` — генерация конфигурации 3proxy;
- `service` — установка и запуск systemd-сервиса;
- `firewall` — установка UFW и открытие портов.

Например, выполнить только настройку сервиса:

```bash
ansible-playbook site.yml --tags service
```

## Проверка

Проверка синтаксиса плейбука:

```bash
ansible-playbook site.yml --syntax-check
```

После применения роли проверьте состояние сервиса на целевом хосте:

```bash
systemctl status 3proxy
```

## Разработка

Проверить роль локально:

```bash
./scripts/check.sh
```

Для запуска той же проверки перед каждым коммитом установите
[`pre-commit`](https://pre-commit.com/) и выполните:

```bash
pre-commit install
pre-commit run --all-files
```

GitHub Actions запускает `scripts/check.sh` на каждый push и pull request.

## Ограничения

- Роль собирает 3proxy из исходного архива на целевом хосте.
- Для загрузки исходного архива целевому хосту нужен доступ к GitHub.
- При включённом UFW роль открывает HTTP-порт, SOCKS-порт и SSH-порт Ansible (`ansible_port` или `22/tcp`).
- Роль не управляет внешними правилами firewall, если `proxy3_use_ufw` отключён.
- Значения UID и GID по умолчанию могут конфликтовать с уже существующими пользователями или группами.

## Лицензия

Проект распространяется по лицензии MIT. Полный текст находится в файле [LICENSE](LICENSE).
