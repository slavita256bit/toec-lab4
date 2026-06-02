#import "@preview/modern-g7-32:0.2.0": *
#import "@local/typst-bsuir-core:1.17.6": *
#import "@preview/zap:0.5.0"
#import "@preview/cetz:0.5.0"
#import "@preview/cetz-plot:0.1.3": plot

#set text(font: "Times New Roman", size: 14pt)
#show math.equation: set text(font: "STIX Two Math", size: 14pt)

#show: gost.with(
  title-template: custom-title-template.from-module(toec-template),
  department: "Кафедра теоретических основ электротехники",
  work: (
    type: "Лабораторная работа",
    number: "4",
    subject: "Исследование резонанса в одиночных колебательных контурах",
    variant: "4",
  ),
  manager: (
    name: "Батюков С. В.",
  ),
  performer: (
    name: "Ермаков В. С.",
//     name: "Каптюг И. М.",
//     name: "Рудаков Г. А.",
    group: "558301",
  ),
  footer: (city: "Минск", year: 2026),
  city: none,
  year: none,
  add-pagebreaks: false,
  text-size: 14pt,
)

#show: apply-toec-styling
#include complex-math

#mathtype-mimic-digits.update(2)

// ==========================================
// БЛОК ВЫЧИСЛЕНИЙ (на печать не выводится)
// ==========================================
// Данные для последовательного контура (Бригада 4)
#let V_ser = (
  U: 3.5,      // С учетом добавки преподавателя
  rk: 29.4,    // Ом
  L: 230,      // мГн
  C: 6.47,     // мкФ
  brigade: 4
)

#let L1_H = V_ser.L * 1e-3
#let C1_F = V_ser.C * 1e-6
#let f0_ser = 1 / (2 * calc.pi * calc.sqrt(L1_H * C1_F))
#let rho_ser = calc.sqrt(L1_H / C1_F)
#let Q_ser = rho_ser / V_ser.rk

// Данные для параллельного контура (Бригада 4)
#let V_par = (
  U: 10,       // В
  C: 7.47,     // мкФ
  L: 403,      // мГн
  rk: 41.4,    // Ом
  Rd1: 5.6,    // кОм
  Rd2: 9.0,    // кОм
  brigade: 4
)

#let L2_H = V_par.L * 1e-3
#let C2_F = V_par.C * 1e-6
#let f0_par = 1 / (2 * calc.pi * calc.sqrt(L2_H * C2_F))
#let rho_par = calc.sqrt(L2_H / C2_F)
#let R0_par = calc.pow(rho_par, 2) / V_par.rk
#let Q_par = rho_par / V_par.rk

#let Rd1_ohm = V_par.Rd1 * 1000
#let Rd2_ohm = V_par.Rd2 * 1000

#let Q1_pr = Q_par / (1 + (R0_par / Rd1_ohm))
#let Q2_pr = Q_par / (1 + (R0_par / Rd2_ohm))

#let Uk0_1 = V_par.U * (R0_par / (R0_par + Rd1_ohm))
#let Uk0_2 = V_par.U * (R0_par / (R0_par + Rd2_ohm))


// ==========================================
// НАЧАЛО ДОКУМЕНТА
// ==========================================

= Цель работы
Экспериментальное исследование частотных и резонансных характеристик последовательного контура, влияния активного сопротивления на вид резонансных кривых. Ознакомление с настройкой последовательного контура на резонанс с помощью емкости. Изучение частотных свойств параллельного колебательного контура, снятие амплитудно-частотных и фазочастотных характеристик.

= Расчет домашнего задания

== Последовательный колебательный контур

Исходные данные варианта #V_ser.brigade представлены в таблице @src-table-1.

#figure(
  caption: [Исходные данные для последовательного контура],
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      [Номер бригады], [$U_"ВХ"$, В], [$r_"k1"$, Ом], [$L_K$, мГн], [$C$, мкФ]
    ),
    [#V_ser.brigade], [#V_ser.U], [#V_ser.rk], [#V_ser.L], [#V_ser.C]
  )
) <src-table-1>

Схема электрической цепи для последовательного соединения представлена на рисунке @src-circuit-1.

#lab-figure(
  above: -1em,
  gap: 1em,
  caption: [Схема для исследования последовательного колебательного контура],
  circuit-better(scale-factor: 80%, {
    import zap: *
    node-better("1", (0, 4), visible: true)
    node-better("2", (12, 4), visible: true)
    node-better("3", (12, 0), visible: true)
    node-better("4", (0, 0), visible: true)

    open-branch-better("U_in", "1", "4", label: $dot(U)$, arrow-side: "left", arrow-dir: "down")

    wire("1", (2,4))
    current-arrow("I", (2,4), (4,4), arrow-label: $dot(I)$, arrow-side: "top", arrow-dir: "forward")
    resistor-better("rk", (4,4), (8,4), label: (content: $r_"k1"$, anchor: "bottom"))
    inductor-better("L", (8,4), "2", label: (content: $L_K$, anchor: "bottom"))

    capacitor-better("C", "2", "3", label: (content: $C$, anchor: "left"), arrow-label: $dot(U)_C$, arrow-side: "right", arrow-dir: "down")

    wire("3", "4")
  })
) <src-circuit-1>

Определим резонансную частоту $f_0$, характеристическое сопротивление $rho$ и добротность контура $Q$.
#mathtype-mimic(spacing: 1em)[
  $ f_0 &= 1 / (2 pi sqrt(L_K C)) = 1 / (2 dot pi dot sqrt(#V_ser.L dot 10^(-3) dot #V_ser.C dot 10^(-6))) = #f0_ser " Гц"; $
  $ rho &= sqrt(L_K / C) = sqrt((#V_ser.L dot 10^(-3)) / (#V_ser.C dot 10^(-6))) = #rho_ser " Ом"; $
  $ Q &= rho / r_"k1" = #rho_ser / #V_ser.rk = #Q_ser. $
]

Зависимости тока в цепи и напряжений на элементах контура от частоты описываются уравнениями:
#mathtype-mimic(spacing: 1em)[
  $ I(f) &= U / sqrt(r_"k1"^2 + (2 pi f L_K - 1 / (2pi""f""C))^2); $
  $ U_C (f) &= I(f) dot 1 / (2pi""f""C); $
  $ U_L (f) &= I(f) dot sqrt(r_"k1"^2 + (2 pi f L_K)^2). $
]

Расчет и построение резонансных кривых тока $I(f)$, напряжения на емкости $U_C (f)$ и напряжения на катушке индуктивности $U_K (f)$ представлены на рисунке @mathcad-series.

#figure(
  gap: 1em,
  image("mathcad/series.png", width: 100%),
  caption: [Резонансные кривые последовательного контура]
) <mathcad-series>


== Параллельный колебательный контур (теоретический расчет)

Исходные данные для параллельного контура представлены в таблице @src-table-2.

#figure(
  caption: [Исходные данные для параллельного контура],
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      [Вариант], [$C$, мкФ], [$U$, В], [$R_("д"1)$, кОм], [$R_("д"2)$, кОм], [$L_2$, мГн], [$r_"k2"$, Ом]
    ),
    [#V_par.brigade], [#V_par.C], [#V_par.U], [#V_par.Rd1], [#V_par.Rd2], [#V_par.L], [#V_par.rk]
  )
) <src-table-2>

Рассчитаем параметры параллельного контура: резонансную частоту $f_0$, характеристическое сопротивление $rho$, эквивалентное сопротивление при резонансе $R_0$ и собственную добротность $Q$.

#mathtype-mimic(spacing: 1em)[
  $ f_0 &= 1 / (2 pi sqrt(L_2 C)) = 1 / (2 dot pi dot sqrt(#V_par.L dot 10^(-3) dot #V_par.C dot 10^(-6))) = #f0_par " Гц"; $
  $ rho &= sqrt(L_2 / C) = sqrt((#V_par.L dot 10^(-3)) / (#V_par.C dot 10^(-6))) = #rho_par " Ом"; $
  $ R_0 &= rho^2 / r_"k2" = (#rho_par)^2 / #V_par.rk = #R0_par " Ом"; $
  $ Q &= rho / r_"k2" = #rho_par / #V_par.rk = #Q_par. $
]

#[
#set par(spacing: 0.8em)
При наличии источника с внутренним (добавочным) сопротивлением $R_"д"$, добротность контура $Q'$ ухудшается. Рассчитаем эквивалентную добротность и напряжение на контуре при резонансе $U_"k0"$ для двух значений сопротивления: $R_("д1") = #_fmt(V_par.Rd1)$ кОм и $R_("д2") = #_fmt(V_par.Rd2)$ кОм.

Для $R_("д1")$:
#v(0.5em)
#mathtype-mimic(spacing: 1em)[
  $ Q'_1 &= Q / (1 + R_0 / R_("д1")) = #Q_par / (1 + #R0_par / #Rd1_ohm) = #Q1_pr ; $
  $ U_("k0"_1) &= U dot R_0 / (R_0 + R_("д1")) = #V_par.U dot #R0_par / (#R0_par + #Rd1_ohm) = #Uk0_1 " В". $
]

#unbreakable[
Для $R_("д2")$:
#mathtype-mimic(spacing: 1em)[
  $ Q'_2 &= Q / (1 + R_0 / R_("д2")) = #Q_par / (1 + #R0_par / #Rd2_ohm) = #Q2_pr ; $
  $ U_("k0"_2) &= U dot R_0 / (R_0 + R_("д2")) = #V_par.U dot #R0_par / (#R0_par + #Rd2_ohm) = #Uk0_2 " В". $
]
]
]
Результаты построения АЧХ и ФЧХ в среде Mathcad представлены на рисунке @mathcad-parallel.

#figure(
  gap: 1em,
  image("mathcad/parallel.png", width: 100%),
  caption: [АЧХ и ФЧХ параллельного колебательного контура]
) <mathcad-parallel>

= Экспериментальная часть

// ==========================================
// ОПЫТНЫЕ ДАННЫЕ
// ==========================================
#let freqs_ser  = (50, 120, 123, 126, 128, 130, 132, 135, 138, 140, 200)
#let exp_I_ser  = (7.4, 64.5, 74.2, 84.6, 91.0, 109.6, 99.7, 98.3, 91.6, 85.7, 20.2)
#let exp_Uk_ser = (0.616, 13.03, 15.62, 18.99, 20.8, 22.5, 24.1, 24.3, 22.2, 20.8, 6.3)
#let exp_Uc_ser = (4.08, 15.77, 18.01, 20.5, 22.2, 23.2, 24.2, 25.2, 20.1, 18.87, 2.74)

#let tbl_ser_content = ()

#for (i, f) in freqs_ser.enumerate() {
  if i == 0 { tbl_ser_content.push(table.cell(rowspan: 5)[До рез.]) }
  if i == 5 { tbl_ser_content.push(table.cell(rowspan: 1)[Рез.]) }
  if i == 6 { tbl_ser_content.push(table.cell(rowspan: 5)[После рез.]) }

  tbl_ser_content.push(_fmt(f, digits: 0))

  let w = 2 * calc.pi * f
  let XL = w * L1_H
  let XC = 1 / (w * C1_F)
  let Z = calc.sqrt(calc.pow(V_ser.rk, 2) + calc.pow(XL - XC, 2))
  let I_calc = V_ser.U / Z
  let UC_calc = I_calc * XC
  let Uk_calc = I_calc * calc.sqrt(calc.pow(V_ser.rk, 2) + calc.pow(XL, 2))

  tbl_ser_content.push(_fmt(I_calc * 1000, digits: 3))
  tbl_ser_content.push(_fmt(exp_I_ser.at(i), digits: 1))

  tbl_ser_content.push(_fmt(UC_calc, digits: 3))
  tbl_ser_content.push(_fmt(exp_Uc_ser.at(i), digits: 2))

  tbl_ser_content.push(_fmt(Uk_calc, digits: 3))
  tbl_ser_content.push(_fmt(exp_Uk_ser.at(i), digits: 2))
}

#unbreakable[
#figure(
  caption: [Резонансные характеристики последовательного контура],
  table(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[Режим],
      table.cell(rowspan: 2)[$f$, Гц],
      table.cell(colspan: 2)[$I$, мА],
      table.cell(colspan: 2)[$U_C$, В],
      table.cell(colspan: 2)[$U_k$, В],
      [Расчет], [Опыт], [Расчет], [Опыт], [Расчет], [Опыт]
    ),
    ..tbl_ser_content
  )
) <res-table-series>
]

// ==========================================
// ОБРАБОТКА ДАННЫХ И ПОСТРОЕНИЕ ГРАФИКОВ
// ==========================================
#let _pair_freqs_with(values, freqs) = {
  let out = ()
  for (i, v) in values.enumerate() {
    out.push((freqs.at(i), v))
  }
  out
}

#let exp_I_pts  = _pair_freqs_with(exp_I_ser, freqs_ser)
#let exp_Uc_pts = _pair_freqs_with(exp_Uc_ser, freqs_ser)
#let exp_Uk_pts = _pair_freqs_with(exp_Uk_ser, freqs_ser)

// Вычисление Z, Xc, XL по опытным данным
#let exp_Z_pts = ()
#let exp_XC_pts = ()
#let exp_XL_pts = ()

#for (i, f) in freqs_ser.enumerate() {
  let I_A = exp_I_ser.at(i) / 1000
  let z_val = V_ser.U / I_A
  let xc_val = exp_Uc_ser.at(i) / I_A

  // X_L = sqrt(Z_k^2 - r_k^2)
  let zk_val = exp_Uk_ser.at(i) / I_A
  let xl_val = 0
  if zk_val * zk_val > V_ser.rk * V_ser.rk {
    xl_val = calc.sqrt(zk_val * zk_val - V_ser.rk * V_ser.rk)
  }

  exp_Z_pts.push((f, z_val))
  exp_XC_pts.push((f, xc_val))
  exp_XL_pts.push((f, xl_val))
}

= Обработка результатов эксперимента

== Расчет и построение частотных характеристик сопротивлений
По экспериментальным данным (таблица 3) рассчитаем значения полного сопротивления цепи $Z$, емкостного сопротивления $X_C$ и индуктивного сопротивления $X_L$:
#mathtype-mimic(spacing: 1em)[
  $ Z(f) = U / I(f); quad X_C (f) = U_C thin f / I(f); quad X_L (f) = sqrt((U_K (f)/I(f))^2 - r_"k1"^2). $
]

Построенные частотные характеристики сопротивлений представлены на рисунке @exp-z-plot. Из графика видно, что точка пересечения кривых $X_C(f)$ и $X_L(f)$ соответствует резонансной частоте контура.

#figure(
  gap: 1em,
  cetz.canvas({
    cetz.draw.set-style(axes: (x: (
      tick: (label: (offset: 1em)),
      label: (offset: -0.5em)
    )))
    plot.plot(
      size: (14, 6),
      axis-style: "left",
      x-label: text(font: "Times New Roman", size: 12pt)[$f$, Гц],
      y-label: text(font: "Times New Roman", size: 12pt)[$Z, X_C, X_L$, Ом],
      x-min: 50, x-max: 200,
      y-min: 0,
      x-tick-step: 25,
      y-tick-step: 200,

      legend: "inner-north-east",
      {
        plot.add(exp_Z_pts,  label: $Z$,    mark: "o", mark-size: 0.10, style: (stroke: blue + 1pt))
        plot.add(exp_XC_pts, label: $X_C$,  mark: "o", mark-size: 0.10, style: (stroke: red + 1pt))
        plot.add(exp_XL_pts, label: $X_L$,  mark: "o", mark-size: 0.10, style: (stroke: green + 1pt))
      }
    )
  }),
  caption: [Частотные характеристики сопротивлений контура],
) <exp-z-plot>

== Построение резонансных характеристик
Совмещенные графики зависимости тока $I$ и напряжений $U_C, U_k$ от частоты, построенные по экспериментальным точкам, показаны на рисунке @exp-series-plot.

#figure(
  gap: 1em,
  cetz.canvas({
    cetz.draw.set-style(axes: (x: (
      tick: (label: (offset: 1em)),
      label: (offset: -0.5em)
    )))
    plot.plot(
      size: (14, 7),
      axis-style: "left",
      x-label: text(font: "Times New Roman", size: 12pt)[$f$, Гц],
      y-label: text(font: "Times New Roman", size: 12pt)[$I$, мА; $U$, В],
      x-min: 50, x-max: 200,
      y-min: 0, y-max: 120,

      x-ticks: (50, 75, 100, 175, 200),
      y-ticks: (0, 20, 40, 60, 100, 120),
      x-tick-step: none,
      y-tick-step: none,

      legend: "inner-north-east",
      {
        plot.add(exp_I_pts,  label: $I$,    mark: "o", mark-size: 0.10, style: (stroke: blue + 1pt))
        plot.add(exp_Uc_pts, label: $U_C$, mark: "o", mark-size: 0.10, style: (stroke: red + 1pt))
        plot.add(exp_Uk_pts, label: $U_k$, mark: "o", mark-size: 0.10, style: (stroke: green + 1pt))

        plot.annotate({
          import cetz.draw: line, content
          let dash-style = (dash: "dashed", paint: gray, thickness: 1pt)

          // Максимальный ток и резонансная частота
          line((50, 109.6), (130, 109.6), stroke: dash-style)
          line((130, 0), (130, 109.6), stroke: dash-style)

          content((50 - 4, 109.6), box(fill: white, inset: 1pt)[$I_0$], anchor: "east")
          content((130, -7), box(fill: white, inset: 1pt)[$f_0$], anchor: "north")

          // Уровень 0.707 и граничные частоты
          line((50, 77.5), (147.5, 77.5), stroke: dash-style)
          line((124, 0), (124, 77.5), stroke: dash-style)
          line((147.5, 0), (147.5, 77.5), stroke: dash-style)

          content((50 - 4, 77.5), box(fill: white, inset: 1pt)[$I_0 / sqrt(2)$], anchor: "east")
          content((124, -7), box(fill: white, inset: 1pt)[$f_1$], anchor: "north")
          content((147.5, -7), box(fill: white, inset: 1pt)[$f_2$], anchor: "north")
        })
      }
    )
  }),
  caption: [Экспериментальные резонансные кривые последовательного контура],
) <exp-series-plot>

== Определение добротности контура различными способами

По графикам на рисунке @exp-series-plot (полоса пропускания) определим добротность:
#mathtype-mimic(spacing: 1em)[
  $ Q = f_0 / (f_2 - f_1) = 130 / (147.5 - 124) = 130 / 23.5 = 5.53. $
]

#mathtype-mimic(spacing: 1em)[
  $ Q = U_("C"0) / U = 23.2 / 3.5 = 6.63. $
]

#mathtype-mimic(spacing: 1em)[
  $ Q = rho / r_"k1" = 188.5 / 29.4 = 6.41. $
]

== Векторные диаграммы

На рисунках @vd-before, @vd-res и @vd-after представлены векторные диаграммы напряжений и токов для трех режимов работы последовательного колебательного контура.

// В качестве опорного вектора выбран вектор тока $dot(I)$, направленный по вещественной оси (для наглядности его длина масштабирована). Напряжение на контуре образуется как сумма векторов напряжений на катушке и конденсаторе: $dot(U) = dot(U)_k + dot(U)_C$.

#figure(
  vector-diagram(
    axes: (x: (0, 4), y: (-5, 2)),
    chain-voltages: true,
    currents: ((val: (re: 3, im: 0), label: $dot(I)$, color: black),),
    voltages: (
      (val: (re: 0.23, im: 0.56), label: move(dx:0.2em, $dot(U)_k$), color: black, anchor: "south"),
      (val: (re: 0, im: -4.08), label: move(dx:0.2em, $dot(U)_C$), color: black, anchor: "north")
    ),
    sum-voltage: (label: $dot(U)$, color: black, anchor: "west")
  ),
  caption: [Векторная диаграмма для $f=50$ Гц ($f < f_0$)]
) <vd-before>

#figure(
  vector-diagram(
    axes: (x: (0, 5), y: (-2, 4)),
    chain-voltages: true,
    currents: ((val: (re: 4, im: 0), label: $dot(I)$, color: black),),
    voltages: (
      (val: (re: 3.48, im: 2.223), label: $dot(U)_k$, color: black, anchor: "west"),
      (val: (re: 0, im: -2.32), label: move(dx: -2em, dy: -1em, $dot(U)_C$), color: black, anchor: "west")
    ),
    sum-voltage: (label: $dot(U)$, color: black, anchor: "north")
  ),
  caption: [Векторная диаграмма для $f=130$ Гц ($f = f_0$)]
) <vd-res>

#figure(
  vector-diagram(
    axes: (x: (0, 4), y: (-1, 8)),
    chain-voltages: true,
    currents: ((val: (re: 3, im: 0), label: $dot(I)$, color: black),),
    voltages: (
      (val: (re: 0.64, im: 6.27), label: $dot(U)_k$, color: black, anchor: "south"),
      (val: (re: 0, im: -2.74), label: move(dy:-0.5em, $dot(U)_C$), color: black, anchor: "west")
    ),
    sum-voltage: (label: $dot(U)$, color: black, anchor: "north-west")
  ),
  caption: [Векторная диаграмма для $f=200$ Гц ($f > f_0$)]
) <vd-after>

#heading(numbering: none)[Вывод]
В ходе выполнения лабораторной работы экспериментально исследован резонанс напряжений в последовательном колебательном контуре. Подтверждено, что на резонансной частоте реактивные сопротивления емкости и индуктивности равны друг другу, полное сопротивление цепи $Z$ становится минимальным. Вследствие этого ток в цепи достигает максимума, а напряжения на реактивных элементах многократно превышают входное напряжение.
