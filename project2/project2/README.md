Project 2 
Gossip Simulator

Team Members:
Arunima Agarwal (UFID: 3397-1331)
Karan Acharekar (UFID: 3868-9483)

Description:	

The purpose of this project is to use Elixir and the actor model to build a gossip simulator which can be used both for group communication and aggregate computation and hence, determine the convergence of both the algorithms as mentioned. 

Gossip Algorithm:

There are four topologies defined in the project full, 2D, imperfect2D and line. We create the neighbor list of each node per the requirement of the topology. We maintain the state of each node which consists of the neighbor list for each node. This neighbor list is created when the GenServer starts the actors and thus calls the build topology for that actor. In this build topology, the neighbor list for each actor is updated in the state.
1.	The main process send a rumor to any random node from the total nodes passed as the arguments.
2.	The random process suppose node4 checks its neighbor list and select random neighbor and pass the rumor to it. This random neighbor check its neighbor list and pass the rumor and it goes on.
3.	Each node maintains a rumor count, as soon as it hears the rumor it increases its count. 
4.	The node stops sending the rumor once the count reaches 10.
5.	So, in each topology once the nodes stop sending i.e. kill their process after their count becomes 10 or the nodes has no neighbors left in the neighbor list, hence at this moment the network will converge and we will determine the convergence time.


Push-Sum Algorithm:

This also should work on the four topologies as defined above. This is used to compute the aggregate which is the ratio of sum/weight. Initially each actor will have weight of and sum equals to its node number.
1.	The main process starts one of the node to start the push-sum algorithm.
2.	This node will have its sum and weight as initialized earlier. It selects some random neighbor from its neighbor list and sends half of its sum and weight to the next node and so on.
3.	The sum estimate is the ratio of sum/weight which is calculate for each node and update it as every node sends the message.
4.	If the ratio computed above did not change more than 10^-10 in 3 consecutive rounds, the node will terminate that stops its process. Hence, at this moment the network will converge.


Systems used:

MacBook Pro: OS 10.12 (quad core)
Lenovo Yoga 710: Windows 10 (quad core)

How to Run:

To run on MAC machine, use the following commands:
mix escript.build
./project2 numNodes topology algorithm 
e.g.: ./project2 100 full gossip

To run on WINDOWS machine, use the following commands:
mix escript.build
escript project2 numNodes topology algorithm 
e.g.: escript project2 100 full gossip

Assumptions:

For the convergence condition in both gossip and push-sum algorithm we have created a polling process that checks the state of each node that stops sending rumor and if the state remains same for some consecutive number of times then the network should converge as it is the stage that the nodes are not receiving any more messages and neither it can send any messages to other nodes.

Project Results:

What is working?

The four topologies i.e. full, 2D, imperfect2D and line are working as expected using gossip and push-sum algorithm. The network is converging according the convergence conditions that we have set in the code(which is mentioned in assumptions). The full network should have only one node left at the end we have verfied this with multiple counts of numNodes.

Largest network managed for each topology:

Goosip Algorithm:

For full topology the largest network was with nodes = 20,000 with convergence time = 3208206 milliseconds
For 2D and imperfect2D topology the largest network was with nodes = 20,164 with convergence time = 1893764 milliseconds and 1766655 milliseconds respectively.
For line topology the largest network was with nodes = 10,000 with convergence time = 155991 milliseconds

Push-Sum Algorithm:

For full topology the largest network was with nodes = 20,000 with convergence time = 5218505 milliseconds
For 2D and imperfect2D topology the largest network was with nodes = 20,164 with convergence time = 1904865 milliseconds and 1153653 milliseconds respectively.
For line topology the largest network was with nodes = 10,000 with convergence time = 134752 milliseconds

