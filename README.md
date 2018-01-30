# vision-puppetdb

[![Build Status](https://travis-ci.org/vision-it/vision-puppetdb.svg?branch=production)](https://travis-ci.org/vision-it/vision-puppetdb)

## Notes

The SSL Certificates for Jetty need to be put in place (readable) in order to start PuppetDB.

Note also that the certificate needs to contain all alternative CNs for the PuppetDB node.

## Parameters

  String `$vision_puppetdb::db_password`: Password for PostgreSQL database (no default)

  String `$vision_puppetdb::db_user`: Username for PostgreSQL database (Default: `puppetdb`)

  Array  `$environment`: Array of environment variables for Docker container (Default: `[]`)

  Array  `$cert_whitelist`: Array of FQDNs for PuppetDB certificate whitelist (Default: `[]`)

  String `$puppetdb_version`: Tag for PuppetDB Docker image (Default: `latest`)

  String `$postgresql_version`: Tag for PostgreSQL Docker image (Default: `latest`)

  String `$ssl_key`: Path to private key for PuppetDB (Default: `/etc/puppetlabs/puppetdb/ssl/jetty_private.pem`)

  String `$ssl_cert`: Path to certificate file for PuppetDB (Default: `/etc/puppetlabs/puppetdb/ssl/jetty_public.pem`)

  String `$explorer_version`: Tag for Puppet Explorer Docker image, set to `undef` to disable this container (Default: `latest`)

## Usage

Include in the *Puppetfile*:

```
mod vision_puppetdb:
    :git => 'https://github.com/vision-it/vision-puppetdb.git,
    :ref => 'production'
```

Include in a role/profile:

```puppet
contain ::vision_puppetdb
```
