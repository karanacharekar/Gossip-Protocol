Project 2 - Bonus
Gossip Simulator

Team Members:
Arunima Agarwal (UFID: 3397-1331)
Karan Acharekar (UFID: 3868-9483)

Description:	

The purpose of this project is to use Elixir and the actor model to build a gossip simulator which can be used both for group communication and aggregate computation and hence, determine the convergence of both the algorithms as mentioned. 

Failure Models:
1)	Node dies: To simulate this model we have created a function which kills some specified number of nodes. This number acts as our parameter that will control the failure model.
2)	Connection dies: To simulate this model we have created a function that selects random node suppose node3 and deletes one or more of its neighbors (suppose node4 and node5). This breaks the connection between node 3 and node 4 and node 3 and node 5. The no. of connections killed act as our parameter that will control the failure model.


Systems used:

MacBook Pro: OS 10.12 (quad core)
Lenovo Yoga 710: Windows 10 (quad core)

How to Run:

To run on MAC machine, use the following commands:
mix escript.build
./project2_bonus numNodes topology algorithm 
e.g.: ./project2_bonus 100 full gossip

To run on WINDOWS machine, use the following commands:
mix escript.build
escript project2_bonus numNodes topology algorithm 
e.g.: escript project2_bonus 100 full gossip

Assumptions:

For the convergence condition in both gossip and push-sum algorithm we have created a polling process that checks the state of each node that stops sending rumor and if the state remains same for some consecutive number of times then the network should converge as it is the stage that the nodes are not receiving any more messages and neither it can send any messages to other nodes.

These are the two functions that we have implemented. For the time being we have commented one function call which is at line number 178. Please uncomment it, to test it (since only one function could work at a time i.e. either the nodes die or the connection dies).

    killnodes(10,list) # <------------------------  KILL 10 NODES 
    killconnection(10,list) # <----------------------- KILL 10 CONNECTIONS


Project Results:

On testing the failure model, the convergence time of the full is the largest while that of line is smallest. Our convergence condition is that the message passing should stop (in both gossip and push-sum) when the sending state remains same for multiple consecutive rounds. Thus, as per the above condition the line topology breaks because of failure nodes and stops sending and converges. Full topology takes longer because it is failure resilient as it is connected to every other node.

