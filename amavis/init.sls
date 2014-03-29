{% if ((grains['os_family'] == 'Debian') or
       (grains['os_family'] == 'RedHat' and
        grains['osmajorrelease'][0] in ['5', '6'])) %}
amavisd-new:
  pkg:
    - installed
  postgres_user.present:
    - name: {{ pillar['amavis']['dbuser'] }}
    - password: {{ pillar['amavis']['dbpass'] }}
    - user: postgres
    - require:
      - pkg: postgresql
  postgres_database.present:
    - name: {{ pillar['amavis']['dbname'] }}
    - owner: {{ pillar['amavis']['dbuser'] }}
    - encoding: UTF8
    - lc_ctype: en_GB.UTF8
    - lc_collate: en_GB.UTF8
    - template: template0
    - user: postgres
    - require:
      - postgres_user: {{ pillar['amavis']['dbuser'] }}
      - file: /etc/locale.gen
  cmd.run:
    - env:
      - PGPASSWORD: '{{ pillar['amavis']['dbpass'] }}'
    - unless: psql -h localhost -U {{ pillar['amavis']['dbuser'] }} {{ pillar['amavis']['dbname'] }} -c "select * from pg_tables where schemaname='public';" | grep users
    - name: psql -h localhost -U {{ pillar['amavis']['dbuser'] }} {{ pillar['amavis']['dbname'] }} < /var/cache/amavis/amavis-pg.sql
    - require:
      - file: /var/cache/amavis/amavis-pg.sql
      - postgres_database: {{ pillar['amavis']['dbname'] }}

/var/cache/amavis/amavis-pg.sql:
  file:
    - managed
    - source: salt://modoboa/amavis-pg.sql
    - require:
      - file: /var/cache/amavis/

/var/cache/amavis/:
  file:
    - directory
    - user: amavis
    - group: amavis
    - mode: 775
    - makedirs: True
    - require:
      - pkg: amavisd-new

{% endif %}
