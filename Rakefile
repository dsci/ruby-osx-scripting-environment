namespace :code do
  desc 'Compiles the sourcode'
  task :compile do
    cmd = <<-SHELL
      clang -fobjc-gc macruby.m -o macruby -framework Foundation -framework MacRuby
    SHELL
    sh cmd
  end
end