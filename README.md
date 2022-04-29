# check_invoiceninja
![alt text](https://www.infiniroot.com/graph/news/973-infiniroot-invoiceninja.png)

Monitoring plugin to check Invoice Ninja application. Right now the plugin only checks for the expiration of an Invoice Ninja license (usually a White Label license).

Support both Invoice Ninja v4 and v5. 


## MySQL preparations
The plugin connects to the Invoice Ninja database and requires read rights on the table companies within Invoice Ninja's database.

Example for Invoice Ninja v4:

```
GRANT SELECT ON invoiceninja.companies TO 'monitoring'@'localhost' IDENTIFIED BY 'secret';
```

Example for Invoice Ninja v5:

```
GRANT SELECT ON invoiceninja.accounts TO 'monitoring'@'localhost' IDENTIFIED BY 'secret';
```


## Run the plugin

### Invoice Ninja v5

```
$ /usr/lib/nagios/plugins/check_invoiceninja.sh -H localhost -u monitoring -p secret -d invoiceninja5
INVOICENINJA OK - white_label license will expire in 216 days
```

With warning threshold (N days):

```
$ /usr/lib/nagios/plugins/check_invoiceninja.sh -H localhost -u monitoring -p secret -d invoiceninja5 -w 250
INVOICENINJA WARNING - white_label license will expire in 216 days
```

### Invoice Ninja v4

By default the plugin assumes it runs against an Invoice Ninja v5 database (since plugin version 1.1). To use Invoice Ninja v4, add the `-v 4` parameter:

```
$ /usr/lib/nagios/plugins/check_invoiceninja.sh -H localhost -u monitoring -p secret -d invoiceninja -v 4
INVOICENINJA WARNING - white_label license will expire in 6 days
```

With a lower warning threshold:

```
$ /usr/lib/nagios/plugins/check_invoiceninja.sh -H localhost -u monitoring -p secret -d invoiceninja -v 4 -w 2
INVOICENINJA OK - white_label license will expire in 6 days
```



## Invoice Ninja Server

Interested in our dedicated managed Invoice Ninja servers? https://www.infiniroot.com/dedicated-hosting/invoiceninja-billing.php
