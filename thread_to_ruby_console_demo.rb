module SW
  module ThreadToConsoleDemo 
    def self.run_demo()
      begin
        p 'starting'
        start_interrupter_thread()
        100000000.times {|i| x = i }
      ensure
        p 'stopping'
        stop_interrupter_thread()
      end
    end
    
    def self.start_interrupter_thread()
      @interrupter_thread = Thread.new() {interrupter_loop()}
      @interrupter_thread.priority = 1
    end
    
    def self.stop_interrupter_thread()
      @interrupter_thread.exit if @interrupter_thread.respond_to?(:exit)
      @interrupter_thread = nil
    end

    def self.interrupter_loop()
      begin
        while true
          sleep(0.5)
          # puts debug info to the ruby console
          Thread_To_Console.add_message("tic") if SW.const_defined?(:Thread_To_Console) 
        end 
      rescue => e
        # puts debug info to the ruby console
        Thread_To_Console.add_message("#{e.to_s}, #{e.backtrace.join("\n")}") if SW.const_defined?(:Thread_To_Console)
      end
    end
  end  
 end
 
SW::ThreadToConsoleDemo.run_demo
nil

