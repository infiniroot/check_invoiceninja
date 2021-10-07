# check_invoiceninja
![alt text](https://www.infiniroot.com/graph/news/973-infiniroot-invoiceninja.png)

Monitoring plugin to check Invoice Ninja application. Right now the plugin only checks for the expiration of an Invoice Ninja license (usually a White Label license).

The plugin connects to the Invoice Ninja database and requires read rights on the table companies within Invoice Ninja's database.

## Run the plugin

```
# /usr/lib/nagios/plugins/check_invoiceninja.sh -H localhost -u monitoring -p secret -d invoiceninja
INVOICENINJA WARNING - white_label license will expire in 14 hours
```

With warning threshold (N days):

```
# /usr/lib/nagios/plugins/check_invoiceninja.sh -H localhost -u monitoring -p secret -d invoiceninja -w 7
INVOICENINJA WARNING - white_label license will expire in 14 hours
```

## Invoice Ninja Server

Interested in our dedicated managed Invoice Ninja servers? https://www.infiniroot.com/dedicated-hosting/invoiceninja-billing.php
