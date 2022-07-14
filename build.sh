#!/bin/bash

moduleName='example'

clean()
{
	rm -f *.o
}

cleanAll()
{
	rm -f *.{o, so}
}

compile()
{
	g++ -std=c++11 -pipe -g -O2 -fstack-protector-strong -Wformat -Werror=format-security  -Wdate-time -D_FORTIFY_SOURCE=2   -DLINUX -D_REENTRANT -D_GNU_SOURCE  -pthread  -I/usr/include/apache2 -I/usr/include/apr-1.0 -I/usr/include -c -o "$moduleName.o" "$moduleName.c"
}

link()
{
	 g++ -std=c++11 -shared  -fPIC -DPIC "$moduleName.o" -Wl,--as-needed -Wl,-Bsymbolic-functions -Wl,-z -Wl,relro -Wl,-z -Wl,now   -Wl,-soname -Wl,"$moduleName.so" -o "$moduleName.so"
}

configure()
{
	rm -f "/usr/lib/apache2/modules/$moduleName.so"
	rm -f "/etc/apache2/mods-available/$moduleName.conf"
	rm -f "/etc/apache2/mods-available/$moduleName.load"
	
	cp -f "$moduleName.so" "/usr/lib/apache2/modules/$moduleName.so"
	printf "<Location /$moduleName>\nSetHandler $moduleName\n</Location>" > "/etc/apache2/mods-available/$moduleName.conf"
	printf "LoadModule $moduleName /usr/lib/apache2/modules/$moduleName.so" > "/etc/apache2/mods-available/$moduleName.load"

	a2enmod "$moduleName" &> /dev/null
}

restart()
{
	systemctl restart apache2
}

cleanAll && compile && link && clean && configure && restart
