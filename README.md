# Introduction to WildFly Glow 

WildFly Glow is a tool that inspects your applications and provides a trimmed 
WildFly server only containing what is needed by your applications.

This allows us to reduce the disk space, memory consumption and amount of configuration needed to start the server. In a cloud environment keeping everything as small as possible is highly desirable.

Underneath the hood it uses a construct called Galleon layers. Layers can depend on each other, and each provides a subset of the server functionality (for example servlet/EJB). The Galleon layers themselves are contained in feature packs.

We will look at the resulting sizes of a server created with the following approaches:

* Zip downloaded from the downloads section on https://wildfly.org
* Provisioned using Galleon
* Provisioned using Glow inspection

The application contains a simple RESTful web service endpoint handling a GET request, with an injected MicroProfile Config property ([DemoResource.java](src/main/java/org/wildfly/vlog/glow/intro/DemoResource.java)).

## Creating the servers
### Zip download
Simply download the latest version of the server and unzip it to
servers/downloaded

### Provisioned using Galleon
We need the Galleon CLI, which can be downloaded [here](https://github.com/wildfly/galleon/releases). Unzip this somewhere.

Note the `--layers` parameter in the below command. This lists the Galleon layers that we want our provisioned server to contain. The list of layers can be found [here](https://docs.wildfly.org/30/Galleon_Guide.html#wildfly_galleon_layers). While this is documented reasonably well, you typically end up including more than you need.

To provision the server run the following command
```shell
$ /path/to/galleon/cli/bin/galleon.sh  install wildfly --dir=servers/galleon --layers=cloud-server,cdi,jaxrs,microprofile-config 
```

### Provisioned using Glow Inspection
First we need to build our application by building it

```shell
$ mvn clean package
```

Next we obtain the Glow CLI from [here](https://github.com/wildfly/wildfly-glow/releases) and unzip it somewhere.

Now we run Glow to inspect the deployment. This in turn determines the layers from functionality found in the application. This is things like classes imported by your application classes, deployment descriptors etc.

We also tell Glow to provision a server using the information about the layers. Essentially it uses Galleon under the hood to do the provisioning but removes the need to search for the layers.

<!-- TODO We need 1.0.0.Beta3 released before -d is supported -->
```shell
$ /path/to/glow/cli/wildfly-glow scan --provision=SERVER -d=servers/glow target/glow-example.war
```
The Galleon and WildFly Glow functionalities are also usable
from the `wildfly-maven-plugin`. See the `galleon` and `glow` profiles of [pom.xml](./pom.xml) for examples.

Notice that the output of the Glow scan outputs the feature packs and layers discovered.


## Inspecting the servers
As a rough indicator of how big the various servers are, we can run the `check-server.sh` script.

It counts the number of `module.xml` files in the server `modules/` directory. These modules are the libraries that make up the server, and take up disk space.

Also, it counts the number of subsystems configured in the `standalone.xml` file, which is an indication of how much memory will be needed by the server at runtime. Less things started means less memory taken! And of course there is less configuration to deal with.

First lets check the downloaded zip:
```shell
# Check the downloaded zip
$ ./check-server.sh servers/downloaded
573 module.xml found
34 subsytems found in standalone-microprofile.xml
```

```shell
# Check the server provisioned with Galleon
$ ./check-server.sh servers/galleon
358 module.xml found
29 subsytems found in standalone.xml
```
```shell
# Check the server provisioned with WildFly Glow
$ ./check-server.sh servers/glow
225 module.xml found
16 subsytems found in standalone.xml
```
Both Galleon and WildFly Glow end up with a smaller server than the downloaded zip, which is not surprising since in both these cases we are slimming the server.

In this case, WildFly Glow gives us a smaller server than Galleon, with zero knowledge needed of the Galleon layers we need and their dependencies.

## Testing the application works in the servers
### Downloaded Server
We need to copy the war into the application before running it
```shell
$ cp target/glow-example.war servers/downloaded/standalone/deployments
$ ./servers/downloaded/bin/standalone.sh 
```
Then in another terminal window
```shell
% curl localhost:8080/glow-example
Hello Stranger%  
```
### Galleon provisioned server
Again we need to copy the war into the application before running it
```shell
$ cp target/glow-example.war servers/galleon/standalone/deployments
$ ./servers/galleon/bin/standalone.sh
```
And in another terminal window
```shell
$ curl localhost:8080/glow-example
Hello Stranger%               
```
### Glow provisioned server
Here the `wildfly-glow scan` from earlier has helpfully copied the deployment into the
provisioned server so all we need to do is to start it
```shell
$ ./servers/glow/bin/standalone.sh
```
Then again, in another terminal window
```shell
$ curl localhost:8080/glow-example
Hello Stranger
```



This was a very quick introduction to WildFly Glow. See the WildFly GLow (documentation)[http://docs.wildfly.org/wildfly-glow/] for descriptions of more advanced usage.

Here is a relative blog post describing the usage of this project: [Using WildFly Glow to provision the Wildfly server](https://weinan.io/2024/01/23/wildfly-glow.html)
