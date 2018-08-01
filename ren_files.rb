$text_to_remove = []
$files_renamed = 0

def action(base_path)
    files = Dir.entries(".")
    printed = false
    for __s in files
        if __s.index('.mp3')
            old_name = String.new(__s)
            $text_to_remove.each do |text|
                strip_text = text.strip!
                if __s.index(text)
                    __s.gsub! text, ''
                elsif strip_text && __s.index(strip_text)
                    __s.gsub! text.strip!, ''
                end
            end
            new_name = __s
            if (old_name <=> new_name) != 0
                if !printed
                    printed = true
                    puts "\n#{base_path}"
                end
                puts "#{old_name} -> #{new_name}"
                $files_renamed += 1
                File.rename(old_name, __s.strip)
            end
        end
    end
end

def init(base_path)
    for d in Dir.entries(".")
        if d == "." || d == ".."
            next
        end
        if File.directory? d
            Dir.chdir(d)
            init Dir.pwd
            action(base_path)
        else
            action(base_path)
        end
        Dir.chdir(base_path)
    end
end

base_path = nil
if ARGV[0]
    if File.directory? ARGV[0]
        base_path = ARGV[0]
        Dir.chdir(ARGV[0])
    end
else
    base_path = Dir.pwd
end

if File.exists?('config.conf')
    f = File.open('config.conf', 'r')
    if f
        while line = f.gets
            if line.strip!.length != 0
                $text_to_remove << line
            end
        end
        if $text_to_remove.length == 0
            puts "no input provided to remove"
            exit
        end
    else
        puts "unable to read file 'config.conf'"
        puts "please check permitions to read the file"
    end
    f.close
else
    puts "config file missing"
    puts "please check if the 'config.conf' file is in the same directory as the ruby script"
    exit
end

if base_path
    init base_path
    puts "\n\nTotal renamed files : #{$files_renamed}"
end
