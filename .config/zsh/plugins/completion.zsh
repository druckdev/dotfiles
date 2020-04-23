## Author:  druckdev
## Created:	2019-08-18

## TelegramCLI msg completion
	function tg-completion() {
		contactList=( $(telegram-cli -W -C -e "contact_list" | tail -n +9 | head -n -2 | grep -vE "(>>>|<<<|»»»|«««)" | sed 's/ /_/g; s/.*\[K//; s/(/\\(/g; s/)/\\)/g; s/"/\\"/g') )
		echo '#compdef msg' >! $ZSH_CONF/completion/_msg
		echo 				>> $ZSH_CONF/completion/_msg
		echo '_arguments "1:<Recipient>:('"$contactList[*]"')"' >> $ZSH_CONF/completion/_msg
	}
