require_relative './ir_sequence'

class Sensor
  attr_accessor :lines, :sp

  def initialize(port)    
    @sp = SerialPort.new(port, baud_rate: 9600, data_bits: 8, stop_bits: 1, parity: SerialPort::NONE)    
    @sp.sync = true
        
    @recv_buffer = Queue.new

    sleep 3

    Thread.new do
      loop do
        response = @sp.gets.strip
        # puts "Response recieved: #{response.light_blue}".light_yellow
        @recv_buffer.enq response
      end
    end.run
  end

  def read_data
    @recv_buffer.deq
  end

  def write_command(command)    
    @sp.write("#{command}\r\n")
    @sp.flush
    # puts "Command sent: #{command.light_blue}".light_yellow    
  end

  def send_command(command)
    write_command(command)    
    read_data
  end

  def read_sequence
    data = send_command 'Sequence?'
    # puts data.light_magenta
    JSON.parse(data).symbolize_keys!.extend(IrSequence)
  end

  def wait_for_ready
    data = send_command 'Ready?'
    # puts data.light_magenta
    raise 'Sensor Error' unless data == 'SENSOR:OK'
  end

end

