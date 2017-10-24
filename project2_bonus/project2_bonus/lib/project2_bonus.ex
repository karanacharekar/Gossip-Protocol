defmodule PROJECT2_BONUS do
  use GenServer
 
  def main(args) do
    args |> parse_args 
  end

  def parse_args([]) do
      IO.puts "No arguments given" 
  end    

  # THIS FUNCTION PARSES ARGUMENTS PASSED # 

  def parse_args(args) do
      {_, [num_nodes,topology,algorithm], _} = OptionParser.parse(args)
      num_nodes = String.to_integer num_nodes
      topology = to_string topology
      algorithm = to_string algorithm
      if topology == "2D" || topology=="imp2D" do
      :timer.sleep(15)
      matrix_dimnsn = round :math.ceil :math.sqrt(num_nodes)
      num_nodes = matrix_dimnsn * matrix_dimnsn
      end
      create_actors(num_nodes,num_nodes,topology,algorithm)
   end


# FULL TOPOLOGY STRUCTURE #

  def full(nid,cur_nid,neighbour_list) when nid<1 do
    neighbour_list
  end
  
  def full(nid,cur_nid,neighbour_list) do
    if(nid != cur_nid) do 
      neighbour_list = [nid|neighbour_list]
    end
     full(nid-1,cur_nid,neighbour_list)
  end

  def get_full_neighbours(nid,cur_nid) do
     full(nid,cur_nid,[])
  end

  def build_full_network(state) do
    total_nodes = Map.get(state,"total_numnodes")
    cur_nid = Map.get(state,"N_id")
    neighbours = get_full_neighbours(total_nodes,cur_nid)
    state = Map.put(state,"neighbours",neighbours)
    state
  end
  
# LINE TOPOLOGY STRUCTURE #
  
  def get_line_neighbours(total_nodes,cur_nid) do
    neighbour_list = []
    
    cond do
      cur_nid == 1 -> neighbour_list = [cur_nid + 1|neighbour_list]
      cur_nid == total_nodes -> neighbour_list = [cur_nid - 1|neighbour_list]
      true -> neighbour_list = [cur_nid + 1|neighbour_list]
      neighbour_list = [cur_nid - 1|neighbour_list]
    end
    neighbour_list
  end
  
  def build_line_network(state) do
    total_nodes = Map.get(state,"total_numnodes")
    cur_nid = Map.get(state,"N_id")
    neighbours = get_line_neighbours(total_nodes,cur_nid)
    state = Map.put(state,"neighbours",neighbours)
    state
  end


# 2D TOPOLOGY STRUCTURE #


  def get_2D_neighbours(dimension,cur_nid) do
    column_number = round :math.fmod cur_nid,dimension
    top = cur_nid - dimension
    neighbour_list = [] 
    if(top>0) do
      neighbour_list = [top|neighbour_list]
    end 
    down = cur_nid + dimension
    if(down <= dimension*dimension) do
      neighbour_list = [down|neighbour_list]
    end
   
    cond do
      column_number == 0 -> neighbour_list = [cur_nid - 1|neighbour_list]
      column_number == 1 -> neighbour_list = [cur_nid+1|neighbour_list]
      true -> neighbour_list = [cur_nid - 1|neighbour_list]
              neighbour_list = [cur_nid + 1|neighbour_list]
    end
    neighbour_list
  end

  def build_2D_network(state) do
    total_nodes = Map.get(state,"total_numnodes")
    dimension = round :math.ceil :math.sqrt(total_nodes)
    total_nodes = dimension*dimension
    Map.put(state,"total_numnodes",total_nodes)
    cur_nid = Map.get(state,"N_id")
    neighbours = get_2D_neighbours(dimension,cur_nid)
    state = Map.put(state,"neighbours",neighbours)
    state
  end

# IMPERFECT 2D TOPOLOGY STRUCTURE #

  def get_imperfect2D_neighbours(total_nodes,dimension,cur_nid) do
    
    neighbour_list = get_2D_neighbours(dimension,cur_nid)
    updated_list = [cur_nid | neighbour_list]
    random_number = get_random(total_nodes, updated_list)
    neighbour_list = [random_number | neighbour_list]
    neighbour_list
  end

  def get_random(total_nodes, list)  do
    random_number = :rand.uniform(total_nodes)
    if(Enum.member?(list,random_number)) do
      random_number = get_random(total_nodes, list)
    end
    random_number
  end

  def build_imperfect2D_network(state) do
    total_nodes = Map.get(state,"total_numnodes")
    dimension = round :math.ceil :math.sqrt(total_nodes)
    total_nodes = dimension*dimension
    Map.put(state,"total_numnodes",total_nodes)
    cur_nid = Map.get(state,"N_id")
    neighbours = get_imperfect2D_neighbours(total_nodes,dimension,cur_nid)
    state = Map.put(state,"neighbours",neighbours)
    state
  end


# KILL NODES andf CONNECTION (30% BONUS PART) #

  def killnodes(killcount,list) do
    if killcount != 0 do
        nid = Enum.random(list)
        node_name = "N" <> Integer.to_string(nid)
        pid = Process.whereis(String.to_atom(node_name))
        list = List.delete(list,nid)
        Process.exit(pid,:normal)
        killnodes(killcount-1,list)
    end
  end


  def killconnection(killcount, list) do
    if killcount != 0 do
        nid = Enum.random(list)
        node_name = "N" <> Integer.to_string(nid)
        state = GenServer.call(String.to_atom(node_name),{:get_state, "gossip"}) 
        neighbour_list = Map.get(state,"neighbours")
        neighbour_list = List.delete(neighbour_list, Enum.random(neighbour_list))
        state = Map.put(state,"neighbours",neighbour_list)
        killnodes(killcount-1, list)
    end
  end

# CREATE NODES BASED ON NUM_NIDES INPUT #

  def create_actors(n,total,topology,algorithm) when n<1 do
    IO.puts "all nodes created"
    start_node =:rand.uniform(total)
    start_time = :os.system_time(:millisecond)
    list = Enum.to_list(1..total)
    if algorithm == "gossip" do
    GenServer.call(String.to_atom("N"<>Integer.to_string(start_node)), {:receive_gossip, "gossip"})
    killnodes(10,list) # <------------------------  KILL 10 NODES 
    #killconnection(10,list) # <----------------------- KILL 10 CONNECTIONS
    convergence_check(total,1,0,0) 
    end
    if algorithm == "push-sum" do
    spawn fn -> GenServer.call(String.to_atom("N"<>Integer.to_string(start_node)), {:receive_pushsum, {0,0}}) end
    convergence_check(total,1,0,0) 
    end
    end_time = :os.system_time(:millisecond)
    IO.puts Integer.to_string(end_time - start_time) <> "MILLI-SECONDS"
  end


  def create_actors(n,total,topology,algorithm) do
    node_name = "N" <> Integer.to_string(n)
    GenServer.start_link(__MODULE__, {n,total,topology,algorithm}, name: String.to_atom(node_name))
    create_actors(n-1,total,topology,algorithm)
  end


# FINDING OUT CONVERGENCE CONDITION #

  def check_all_nodes(count,num,total) do
      if num < total+1 do
      node_name = "N" <> Integer.to_string(num)
      state = GenServer.call(String.to_atom(node_name),{:get_state, "gossip"}) 
      if(Map.get(state,"send_active") == true) do 
          count = count + 1
      end
      check_all_nodes(count,num+1,total)
      else
      count
      end
      end

  def convergence_check(total,n,count,repeat) do
    count = check_all_nodes(0,1,total)
    if(count !=0 and count == n ) do
        if(repeat==10) do
            IO.puts(" ............  CONVERGED ...........")
        else
            repeat = repeat + 1
            :timer.sleep(100)
            convergence_check(total,count,0,repeat)
        end
    else
          repeat =0
          convergence_check(total,count,0,repeat)
    end  
  end

# SET TOPOLOGIES FOR EACH NODE #

  def init(args) do

    total_nodes = elem(args,1)
    nid = elem(args,0)
    topology = elem(args,2)
    algorithm = elem(args,3)
    weight = 1

    if algorithm == "gossip" do
    map =  %{"N_id" => nid,"total_numnodes" => total_nodes, "neighbours" => []}    
    else
    map = %{"N_id" => nid,"total_numnodes" => total_nodes, "neighbours" => [], "sum" => nid, "weight"=> weight}
    end

    if topology == "full" do
    state = build_full_network(map)
    end

    if topology == "2D" do
    state = build_2D_network(map)
    end

    if topology == "line" do
    state = build_line_network(map)
    end

    if topology == "imp2D" do
    state = build_imperfect2D_network(map)
    end
    {:ok,state}
  end


# MESSAGE SENDER FOR GOSSIP ALGORITHM #

  def gossip_sender(neighbours) do
    nid = Enum.random(neighbours)
    node_name = "N"<>Integer.to_string(nid)
    GenServer.call(String.to_atom(node_name), {:receive_gossip, "gossip"})
    gossip_sender(neighbours)
  end

# MESSAGE SENDER FOR PUSHSUM ALGORITHM #

  def pushsum(neighbours,tuple_val) do
    nid = Enum.random(neighbours)
    node_name = "N"<>Integer.to_string(nid)
    pid = Process.whereis(String.to_atom(node_name))
    
    if(pid != nil && Process.alive?(pid) == true) do
    GenServer.call(String.to_atom(node_name), {:receive_pushsum, tuple_val})
    else
        neighbours = List.delete(neighbours,nid)
    end
    pushsum(neighbours,tuple_val)
  end
   
  #  ALL CALLBACKS #

  def handle_call({:get_state ,new_message},_from,state) do  
    {:reply,state,state}
  end

  def handle_call({:receive_gossip, gossip},_from,state) do
    
    neighbours = Map.get(state,"neighbours")
    nid = Map.get(state,"N_id")
     
    if(Map.get(state,"sender_process") == nil) do
        sender_pid = spawn fn -> gossip_sender(neighbours) end 
        state = Map.put(state,"sender_process",sender_pid)  
    end

    if(Map.get(state,"gossip_count") == nil) do
        state = Map.put(state,"gossip_count",0) 
    end

    received_gossip_count = Map.get(state,"gossip_count")
    received_gossip_count = received_gossip_count + 1
    state = Map.put(state,"gossip_count",received_gossip_count)
    
    if(received_gossip_count == 10) do
      Process.exit(Map.get(state,"sender_process"), :kill) 
      state = Map.put(state, "send_active", true)
    end
    {:reply,state,state}
  end
  

  def handle_call({:receive_pushsum, gossip}, _from, state) do
    
    neighbours = Map.get(state,"neighbours")
    sum_received = elem(gossip,0)
    weight_received = elem(gossip,1)
    sum = Map.get(state,"sum")
    weight = Map.get(state,"weight")
    previous_sw_ratio = 1
    
    if(weight != 0) do
    previous_sw_ratio = sum/weight
    end
    
    sum = sum + sum_received
    weight = weight + weight_received
    sum_to_send = sum/2
    weight_to_send = weight/2
    state = Map.put(state,"sum",sum_to_send)
    state = Map.put(state,"weight",weight_to_send)
    
    if(Map.get(state,"send_active") == nil) do
      if(Map.get(state,"sender_process") != nil) do
        pid = Map.get(state,"sender_process")
        Process.exit(pid,:kill)
      end
      sender_pid = spawn fn -> pushsum(neighbours, {sum_to_send,weight_to_send}) end
      state = Map.put(state,"sender_process",sender_pid)  
    else
       if(Map.get(state,"sender_process") != nil) do
        pid = Map.get(state,"sender_process")
        state = Map.delete(state,"sender_process")
        Process.exit(pid,:kill)
      end
    end

    ratio = sum_to_send/weight_to_send;
    
    if(Map.get(state,"ratio_repeat") == nil) do
      state = Map.put(state,"ratio_repeat",0)
    end
    
    repeat_count = Map.get(state,"ratio_repeat")
    if(abs(previous_sw_ratio - ratio) < 0.0000000001) do
      repeat_count = repeat_count + 1
      state = Map.put(state, "ratio_repeat", repeat_count)
    end
      
    if(abs(previous_sw_ratio - ratio) > 0.0000000001) do
      repeat_count = 0
      state = Map.put(state, "ratio_repeat", repeat_count)
    end
    
    if(repeat_count != nil && repeat_count >= 3 && Map.get(state,"send_active") == nil) do
      state = Map.put(state, "send_active", true)
      if(Map.get(state,"sender_process") != nil) do
        pid = Map.get(state,"sender_process")
        state = Map.delete(state,"sender_process")
        Process.exit(pid,:kill)
      end
    end
    {:reply,state,state}
    end
end
