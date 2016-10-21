# Introduction

The purpose of this repository is to play around with a GlusterFS
volume that is replicated across several Docker containers.



## Start containers

1. Create the host directories where the glusterfs replicas will store their
   volume bricks:

        mkdir -p server{1,2,3}-vol
	
2. Create host directories where glusterfs replicas will store their 
   identity, cluster state, etc. This is, for instance, necessary to allow 
   a failed replica to restart and re-join the cluster with the same identity.
   
        mkdir -p server{1,2,3}-state


3. Start

        docker-compose up -d && docker-compose logs -f



## Set up replicated volume

1. Set up trusted storage pool:

    On `server1`: 

        docker exec -it server1  bash
        gluster peer status
        gluster peer probe server2
        gluster peer probe server3
        gluster peer status

    On `server2`:

        docker exec -it server2  bash
        gluster peer probe server1
	 
2. Create volume:

    On `server1`:
	
	    gluster volume create vol1 replica 3 \
		  server1:/data/glusterfs/vol1/brick1/brick \
		  server2:/data/glusterfs/vol1/brick1/brick \
		  server3:/data/glusterfs/vol1/brick1/brick
		  
		gluster volume info   # should show 'Status: Created'

3. Start volume:

    On `server1`:

        gluster volume start vol1
		gluster volume info   # should show 'Status: Started'
		gluster volume status
	 
	 
	 
### Mount volume on clients

1. Mount gluster volume as described in [setting up GlusterFS clients](https://gluster.readthedocs.io/en/latest/Administrator%20Guide/Setting%20Up%20Clients/):

    On `client1`:
	
        docker exec -it client1 bash
		mkdir -p /mnt/glusterfs/data
        mount -t glusterfs server1:/vol1 /mnt/glusterfs/data

    On `client2`:
	
        docker exec -it client2 bash
		mkdir -p /mnt/glusterfs/data
        mount -t glusterfs server1:/vol1 /mnt/glusterfs/data
		
2. Play around with files under `/mnt/glusterfs/data` and make sure writes
   on one client are seen on the other client. For example,

    On `client1`:
		
        docker exec -it client1 bash
		export TERM=xterm
		while true; do echo $(date +%s) > /mnt/glusterfs/data/time.txt ; sleep 1s; done

    On `client2`:

        docker exec -it client2 bash
		export TERM=xterm
        watch -n 1 cat /mnt/glusterfs/data/time.txt
   
   
   
   
### Play around with storage pool membership


#### Remove and re-create a replica


    docker-compose stop server2 && docker-compose rm -f server2

    
It should be shown as `Disconnected` on `server1` and `server3`:
   
    gluster peer status    # server2 should be shown as 'Disconnected'
	gluster volume status  # should not appear in list of bricks

Re-create the replica container:

    docker-compose up -d server2

This should make it appear as `Connected` again in `gluster peer status`.

*Note: this should work even when killing server1, which the clients used to 
mount the volume.*





Bring down server from which clients mounted
