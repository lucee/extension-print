# Lucee Print Extension

[![Java CI](https://github.com/lucee/extension-print/actions/workflows/main.yml/badge.svg)](https://github.com/lucee/extension-print/actions/workflows/main.yml)

Provides CFML print tags and functions for Lucee

Basic compatibility with the Adobe implementation (which is broken in ACF 2023 and ACF 2025)

Initial version just supports local printers

Requires Lucee 6.2.1.122 or newer

# Future Plans

Libaries used

## Network printer resolution, using the bonjour protocol (ipp)

https://github.com/jmdns/jmdns
https://javadoc.io/doc/org.jmdns/jmdns/latest/index.html

getPrinterList(network:boolean)

### Network

- false, returns a list of local printers
- true, returns an array containing structs detailing the available printers, including, `name`, `url` and `properties`

## Network printing using IPP

https://github.com/gmuth/ipp-client-kotlin
https://javadoc.io/doc/de.gmuth/ipp-client/latest/index.html

Docs: https://docs.lucee.org/categories/print.html

Issues: https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20%22print%22

Releases: https://download.lucee.org/#96D2AC81-9926-4B9A-B2FC5ED770C54217
