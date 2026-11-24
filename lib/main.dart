
import 'package:flutter/material.dart';

class Tela1 extends StatefulWidget {
  const Tela1({super.key});

  @override
  State<Tela1> createState() => _Tela1State();
}

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Simulador de Campeonato de E-Sports',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const Tela1(),
      ),
    );

Widget campo(String rotulo, TextEditingController ctrl,
    {bool numerico = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      decoration: InputDecoration(
        labelText: rotulo,
        border: const OutlineInputBorder(),
      ),
      controller: ctrl,
      keyboardType: numerico
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
    ),
  );
}

class _Tela1State extends State<Tela1> {
  final diasCtrl = TextEditingController();
  String? erro;
  final nomeCtrl = TextEditingController();
  final timesCtrl = TextEditingController();

  void avancar() {
    final dias = int.tryParse(diasCtrl.text) ?? 0;
    final nome = nomeCtrl.text.trim();
    final times = int.tryParse(timesCtrl.text) ?? 0;

    if (dias <= 0) {
      setState(() => erro = 'A duração do evento deve ser maior que zero.');
    } else if (nome.isEmpty) {
      setState(() => erro = 'Informe o nome do organizador.');
    } else if (times <= 0) {
      setState(() => erro = 'A quantidade de times deve ser maior que zero.');
    } else {
      setState(() => erro = null);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Tela2(nome: nome, times: times, dias: dias),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            campo('Quantidade de Times Participantes', timesCtrl),
            campo('Nome do Organizador / Head Admin', nomeCtrl,
                numerico: false),
            campo('Duração do Evento (dias)', diasCtrl),
            if (erro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(erro!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: avancar,
              child: const Text('Avançar para Infraestrutura'),
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text('Configuração Inicial')),
    );
  }
}

class Tela3 extends StatefulWidget {
  final double custoInfra, custoPremiacao, custoAlimentacao, custoBruto;
  final int times, dias, totalJogadores;
  final String nome;

  const Tela3({
    super.key,
    required this.nome,
    required this.times,
    required this.dias,
    required this.totalJogadores,
    required this.custoInfra,
    required this.custoPremiacao,
    required this.custoAlimentacao,
    required this.custoBruto,
  });

  @override
  State<Tela3> createState() => _Tela3State();
}

class Tela2 extends StatefulWidget {
  final int times;
  final String nome;
  final int dias;

  const Tela2({
    super.key,
    required this.nome,
    required this.times,
    required this.dias,
  });

  @override
  State<Tela2> createState() => _Tela2State();
}

class _Tela2State extends State<Tela2> {
  String? erro;
  final custoCtrl = TextEditingController();
  final jogCtrl = TextEditingController();
  final premCtrl = TextEditingController();

  void avancar() {
    final custoDiario =
        double.tryParse(custoCtrl.text.replaceAll(',', '.')) ?? 0;
    final jogadoresPorTime = int.tryParse(jogCtrl.text) ?? 0;
    final premiacao =
        double.tryParse(premCtrl.text.replaceAll(',', '.')) ?? 0;

    if (jogadoresPorTime <= 0 || premiacao <= 0 || custoDiario <= 0) {
      setState(() => erro =
          'Jogadores por time, premiação e custo diário devem ser maiores que zero.');
      return;
    }

    setState(() => erro = null);

    final totalJogadores = widget.times * jogadoresPorTime;
    final custoAlimentacao = totalJogadores * widget.dias * 40.00;
    final custoPremiacao = widget.times * premiacao;
    final custoInfra = totalJogadores * custoDiario * widget.dias;
    final custoBruto = custoInfra + custoPremiacao + custoAlimentacao;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Tela3(
          nome: widget.nome,
          times: widget.times,
          dias: widget.dias,
          totalJogadores: totalJogadores,
          custoInfra: custoInfra,
          custoPremiacao: custoPremiacao,
          custoAlimentacao: custoAlimentacao,
          custoBruto: custoBruto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Times: ${widget.times}'),
            campo('Valor da Premiação por Time (R\$)', premCtrl),
            Text('Organizador: ${widget.nome}'),
            Text('Duração: ${widget.dias} dia(s)'),
            const SizedBox(height: 16),
            campo('Custo Diário de Energia/Internet por Jogador (R\$)',
                custoCtrl),
            campo('Quantidade de Jogadores por Time', jogCtrl),
            if (erro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(erro!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: avancar,
              child: const Text('Avançar para Arrecadação'),
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text('Infraestrutura e Premiação')),
    );
  }
}

class _Tela3State extends State<Tela3> {
  double saldo = 0;
  final bandaCtrl = TextEditingController();
  double banda = 0;
  String? erro;
  double arrecadacao = 0;
  bool calculado = false;
  final arrecCtrl = TextEditingController();

  void calcular() {
    final b = double.tryParse(bandaCtrl.text.replaceAll(',', '.'));
    final arrec = double.tryParse(arrecCtrl.text.replaceAll(',', '.'));

    if (b == null || b < 1 || b > 100) {
      setState(() {
        erro = 'A taxa de banda deve estar entre 1 e 100.';
        calculado = false;
      });
      return;
    }

    if (arrec == null || arrec < 0) {
      setState(() {
        erro = 'Informe uma arrecadação válida.';
        calculado = false;
      });
      return;
    }

    setState(() {
      saldo = arrec - widget.custoBruto;
      arrecadacao = arrec;
      banda = b;
      erro = null;
      calculado = true;
    });
  }

  void avancar() {
    final riscoLag = banda > 85;
    final fatorEstresse = (banda / 10) * widget.dias;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Tela4(
          nome: widget.nome,
          times: widget.times,
          dias: widget.dias,
          totalJogadores: widget.totalJogadores,
          custoInfra: widget.custoInfra,
          custoPremiacao: widget.custoPremiacao,
          custoAlimentacao: widget.custoAlimentacao,
          custoBruto: widget.custoBruto,
          arrecadacao: arrecadacao,
          saldo: saldo,
          banda: banda,
          fatorEstresse: fatorEstresse,
          riscoLag: riscoLag,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            campo('Taxa de Uso da Banda de Transmissão (%) de 1 a 100',
                bandaCtrl),
            Text(
                'Custo Operacional Bruto: R\$ ${widget.custoBruto.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            campo('Arrecadação Total de Patrocínios e Ingressos (R\$)',
                arrecCtrl),
            if (erro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(erro!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: calcular,
              child: const Text('Calcular Saldo'),
            ),
            if (calculado) ...[
              const SizedBox(height: 16),
              if (banda > 85)
                const Text(
                  'Alerta: risco alto de lag (banda acima de 85%).',
                  style: TextStyle(color: Colors.orange),
                ),
              Text(
                'Saldo Final: R\$ ${saldo.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: saldo < 0 ? Colors.red : Colors.green,
                ),
              ),
              if (saldo < 0)
                const Text(
                  'Atenção: Déficit Financeiro Detectado!',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: avancar,
                child: const Text('Ver Relatório Final'),
              ),
            ],
          ],
        ),
      ),
      appBar: AppBar(title: const Text('Arrecadação e Risco de Rede')),
    );
  }
}

class Tela4 extends StatelessWidget {
  final double arrecadacao, saldo, banda, fatorEstresse;
  final bool riscoLag;
  final int times, dias, totalJogadores;
  final double custoInfra, custoPremiacao, custoAlimentacao, custoBruto;
  final String nome;

  const Tela4({
    super.key,
    required this.nome,
    required this.times,
    required this.dias,
    required this.totalJogadores,
    required this.custoInfra,
    required this.custoPremiacao,
    required this.custoAlimentacao,
    required this.custoBruto,
    required this.arrecadacao,
    required this.saldo,
    required this.banda,
    required this.fatorEstresse,
    required this.riscoLag,
  });

  String reais(double v) => 'R\$ ${v.toStringAsFixed(2)}';

  String get status {
    if (saldo >= 0 && banda <= 85) {
      return 'Evento de Sucesso Absoluto (Sem Lag e Com Lucro)';
    } else if (saldo >= 0 && banda > 85) {
      return 'Lucrativo, mas com Instabilidade de Rede';
    }
    return 'Evento Prejudicial (Prejuízo Financeiro)';
  }

  Widget titulo(String texto) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(texto,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nome,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            titulo('Resumo Logístico'),
            Text('Total de jogadores: $totalJogadores'),
            Text('$dias dia(s) de evento'),
            Text('$times times'),

            titulo('Financeiro'),
            Text('Arrecadação: ${reais(arrecadacao)}'),
            Text(
              'Saldo em Caixa: ${reais(saldo)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: saldo < 0 ? Colors.red : Colors.green,
              ),
            ),

            titulo('Custos'),
            Text('Alimentação: ${reais(custoAlimentacao)}'),
            Text('Infraestrutura: ${reais(custoInfra)}'),
            Text('Custo Operacional Bruto: ${reais(custoBruto)}'),
            Text('Premiações: ${reais(custoPremiacao)}'),

            titulo('Status Final do Evento'),
            Text(status,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            titulo('Rede e Servidores'),
            Text(
                'Fator de estresse dos servidores: ${fatorEstresse.toStringAsFixed(1)}'),
            Text('Taxa de uso da banda: ${banda.toStringAsFixed(1)}%'),
            Text(
              'Risco de lag: ${riscoLag ? "ALTO" : "Baixo"}',
              style: TextStyle(
                color: riscoLag ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Tela1()),
                  (route) => false,
                );
              },
              child: const Text('Novo Campeonato'),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Relatório Final'),
        automaticallyImplyLeading: false,
      ),
    );
  }
}
