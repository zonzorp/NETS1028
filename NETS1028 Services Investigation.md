# NETS1028 Services Investigation
For each of the services installed (whether or not they are running) on your Ubuntu server, create a report showing the following.

1. Service Name
1. Service Software Source (i.e. what package does it belong to)
1. Service User Account(s)
1. Is the service required or optional
1. A brief description of the service
1. Any known security concerns with the service
1. If the service is optional, can it be removed without impacting the system, or only disabled

You can get a complete list of the services running on your server by running the initctl and service commands.

Not all services will have running processes and some may require more effort to determine the source package name. Please do not submit copies of manual pages, installation guides, or other lengthy descriptions of the services as it makes it very difficult to determine which parts are your own work. Only submit the 7 data items for each service as requested by the assignment. If you require assistance completing the assignment, please let me know, and I will try to help you get through it.

### Example: service name "atd"

* `dpkg -l atd` tells us that the atd service is not the name of a software package.
* So we need to find which package atd came from.
* `dpkg -S $(which atd)` tells us that the atd program came from a package named at.
* `ps -ef| grep atd` shows us that there is an atd process running as user daemon. For some services, you may have no processes, or multiple processes with multiple users.
* `dpkg -l at` tells us the brief package description is **Delayed job execution and batch processing**. There are more detailed descriptions we can find, but this is sufficient for our use.
* `apt-cache show at` tells us that the package is **Priority: optional** so it is not required, although we do not know what will be affected by removing it until we check for reverse dependencies.
* `apt-cache rdepends at` tells us there are several packages which depend on at being installed, and checking them with `dpkg -l` tells us none of them are installed. So our dependencies list will be empty on this system and the at service can be removed if we ourselves do not require its functionality.
* A quick search on cve-details.com for the package name **at** shows no list of vulnerabilities. We could start scouring the net, but for our purposes, the lack of recognized problems is sufficient to show we know how to find significant issues.
* So the summary information for the assignment for service atd looks like this:
```
Name: atd
Package: at
User: daemon
Description: Delayed job execution and batch processing
Required? optional
Vulnerabilities: none on cve-details.com
Reverse Dependencies: none on this system
```
Your report must be in pdf form and submitted to blackboard.
