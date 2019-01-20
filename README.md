# mcn-source-ct

Part of my [MCN](https://github.com/search?q=user%3AKagee+mcn+in%3Aname&type=Repositories) (make clean no)-project.

Scripts for downloading and extracting .no domains from the data of the commoncrawl.org project.

Howto:
* git submodule init
* git submodule update
* sudo apt install python-bs4 parallel
* ./get-indexes.sh
* ./verify-indexes.sh
* ./list_domains.sh

Source: http://commoncrawl.org
Description: Looks for domains in data from the Common Crawl project.
Credit: This result uses data from the Common Crawl Foundation, their term of service may be found here http://commoncrawl.org/terms-of-use/
