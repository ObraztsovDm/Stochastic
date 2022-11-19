require 'benchmark'

count_ns = 0
thickness = 0.0
pa = 0.0
kr = 0.0
mu = 0.0
hade = 0.0

=begin
hade = 45.0
thickness = 2.0
count_ns = 5

mu = 1.0
pa = 0.01
kr = 1.0
=end

puts "Характеристики випромінювання та шару речовини\n\n"

while 1
  begin
    puts "Товщина шару:"
    thickness = Float(STDIN.gets.chomp)

    if thickness > 0
      break
    else
      puts "Значення поза допустимим діапазоном. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Не коректне значення. Повторіть вибір"
  end
end

while 1
  begin
    puts "Кут падіння:"
    hade = Float(STDIN.gets.chomp)

    if hade >= 0 and hade <= 360
      break
    else
      puts "Значення поза допустимим діапазоном. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Не коректне значення. Повторіть вибір"
  end
end

puts "\nХарактеристики процесу взаємодії частинок із речовиною\n\n"

while 1
  begin
    puts "Ймовірність поглинання:"
    pa = Float(STDIN.gets.chomp)

    if pa >= 0 and pa <= 1
      break
    else
      puts "Помилка. Значення цього параметру має бути в діапазоні від 0 до 1"
    end
  rescue ArgumentError
    puts "Не коректне значення. Повторіть вибір"
  end
end

while 1
  begin
    puts "Модельний параметр індикатриси розсіювання:"
    kr = Float(STDIN.gets.chomp)

    if kr >= 0
      break
    else
      puts "Значення поза допустимим діапазоном. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Не коректне значення. Повторіть вибір"
  end
end

while 1
  begin
    puts "Довжина вільного пробігу:"
    mu = Float(STDIN.gets.chomp)

    if mu > 0
      mu = 1 / mu
      break
    else
      puts "Значення поза допустимим діапазоном. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Не коректне значення. Повторіть вибір"
  end
end

puts "\nПараметр методу Монте-Карло\n\n"

while 1
  begin
    puts "Статистика (Ns):"
    count_ns = Integer(STDIN.gets.chomp)

    if count_ns > 0
      break
    else
      puts "Значення поза допустимим діапазоном. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Введено не ціле значення. Повторіть вибір"
  end
end

def calculation(count_ns, thickness, pa, kr, mu, hade)
  f_var = 0.0
  b_var = 0.0
  ab_var = 0.0

  start_measurement = Time.now.to_f

  (1..count_ns).each do
    x = 0.0 # координата поверхні шару, що опромінюється

    if hade == 90.0 or hade == 270.0
      #cs = 6.123031769111886e-17
      cs = 0.0
    else
      cs = Math.cos(Math::PI * hade / 180.0) # значення кута в радіанах
    end
    while 1
      l = -Math.log(rand(0.0..1.0)) / mu # формула 1.1
      x1 = x + l * cs # формула 1.2 та 1.3 (через перезапис значень на кожній ітерації)

      if x1 < 0 # умова виходу "назад"
        b_var += 1
        break
      end

      if x1 > thickness # умова виходу "вперед"
        f_var += 1
        break
      end

      r = rand(0.0..1.0) # умова поглинання (формула 1.4)
      if r < pa
        ab_var += 1
        break
      end

      com = rand(0.0..1.0) ** (1 / (kr + 1)) # формула 1.6
      fi = 2 * Math::PI * rand(0.0..1.0) # формула 1.7
      cos_1 = cs * com - Math.sqrt((1 - cs * cs) * (1 - com * com)) * Math.sin(fi) # за формулою cos^2 + sin^2 = 1; використовується формула 1.8

      x = x1
      cs = cos_1
    end
  end

  end_measurement = Time.now.to_f

  q_var1 = (f_var.to_f / count_ns.to_f).round(4) # ймовірність виходу частинки "вперед"
  q_var2 = (b_var.to_f / count_ns.to_f).round(4) # ймовірність виходу частинки "назад"
  q_var3 = (ab_var.to_f / count_ns.to_f).round(4) # ймовірність поглинання частинки

  # розрахунок похибок
  f_ns = Math.sqrt(q_var1 * (1 - q_var1).abs / count_ns.to_f).round(5)
  b_ns = Math.sqrt(q_var2 * (1 - q_var2).abs / count_ns.to_f).round(5)
  ab_ns = Math.sqrt(q_var3 * (1 - q_var3).abs / count_ns.to_f).round(5)

  # хеш отриманих значень
  {
    :Q_F => q_var1,
    :Q_B => q_var2,
    :Q_Ab => q_var3,
    :F_Ns => f_ns,
    :B_Ns => b_ns,
    :Ab_Ns => ab_ns,
    :time_start => start_measurement,
    :time_end => end_measurement
  }
end

puts "\nРезультати моделювання\n\n"
results = calculation(count_ns, thickness, pa, kr, mu, hade)
dispersion_qf = results.dig(:Q_F) * (1 - results.dig(:Q_F))
dispersion_qb = results.dig(:Q_B) * (1 - results.dig(:Q_B))
dispersion_qab = results.dig(:Q_Ab) * (1 - results.dig(:Q_Ab))
laboriousness = ((dispersion_qf + dispersion_qb + dispersion_qab) / 3.0) * ((results.dig(:time_end) - results.dig(:time_start)) / 3.0)
puts("Передавальне відношення: #{results.dig(:Q_F)} :::: Похибка: #{results.dig(:F_Ns)}")
puts("Коефіцієнт відбиття:     #{results.dig(:Q_B)} :::: Похибка: #{results.dig(:B_Ns)}")
puts("Коефіцієнт поглинання:   #{results.dig(:Q_Ab)} :::: Похибка: #{results.dig(:Ab_Ns)}")
puts("Трудомісткість:          #{laboriousness} с.")
