

init: clean
	mkdir -p server1-state
	mkdir -p server1-vol
	mkdir -p server2-state
	mkdir -p server2-vol
	mkdir -p server3-state
	mkdir -p server3-vol


clean:
	sudo rm -rf server*-state
	sudo rm -rf server*-vol
