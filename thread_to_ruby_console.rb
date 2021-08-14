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

  
  ##########################
  # degugging aids
  ##########################

  if true #false # Shall we load the signal trap?
    module Thread_To_Console
      # Functional Description:
      # Module Thread_To_Console is a SIGINT handler that interrupts and executes code
      # on the main thread. By default it will 'puts' an object to the ruby
      # console or alternatively it will call a user supplied Proc object. This
      # mechanism allows a worker thread to execute code on the main Sketchup
      # thread which has the persmissions needed to interact with the Sketchup
      # API. See the warning below.
      #
      # init()                Sets up the SIGINT handler
      # add_message(message)  Add a message to the queue and throw the SIGINT interrupt
      #
      # WARNING - Do not blithely add a SIGINT handler to your ruby code, it is
      # not safe. This code is for debug purposes only!!! This is because signal
      # handlers are reentrant, that is, a signal handler can be interrupted by
      # another signal (or sometimes the same signal) which can cause mysterious
      # errors.
      #
      # further reading http://kirshatrov.com/2017/04/17/ruby-signal-trap/
      # also see self pipe https://gist.github.com/mvidner/bf12a0b3c662ca6a5784
      # and https://bugs.ruby-lang.org/issues/14222
      #
      
      @pending_messages = []

      def self.init()
        @old_signal_handler = Signal.trap("INT") do
          if @pending_messages.size != 0
            current_job = @pending_messages.shift
            if current_job.is_a?(Proc)
                current_job.call
            else
              puts current_job
            end
          else
            # Call the daisy chained signal handler if there is nothing in our
            # pending_messages queue. We should never get here in normal debugging 
            p 'old signal handler called'
            @old_signal_handler.call if @old_signal_handler.respond_to?(:call)
          end
        end #end of Signal.trap do
        
        puts "#{self} chained to the old SIGINT Handler: #{@old_signal_handler.to_s}" 
      end
      
      # Add a message to the queue and trigger the SIGINT on the main thread
      def self.add_message(message)
        @pending_messages << message
        Process.kill("INT", Process.pid)
      end
      
      Thread_To_Console.init()
      
    end # end module Thread_To_Console
  end # if true/false
end

SW::ThreadToConsoleDemo.run_demo
nil

