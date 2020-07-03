
function validar(doc::Doc2011)
	validar_documento(doc)
	for conta in doc.contas
		validar_conta(conta)
	end
	return true
end

function validar_documento(doc::Doc2011)
	assert_contas_repetidas(doc)
	assert_formulas(doc)
end

function validar_conta(conta::Conta)
	assert_codigo_conta(conta)
	assert_soma_detalhes(conta)
	assert_sinal(conta)
	assert_tem_detalhe(conta)
	for detalhe in conta.detalhes
		validar_detalhe(detalhe)
	end
end

function validar_detalhe(detalhe::DetalheConta)
	assert_sinal(detalhe)
end

function assert_contas_repetidas(doc::Doc2011)
	codigos = [conta.codigo for conta in doc.contas]
	@assert length(doc.contas) == length(unique(codigos)) "contas com codigos repetidos"
end

function assert_soma_detalhes(conta::Conta)
	if length(conta.detalhes) > 0
		soma = sum([elem.valor for elem in conta.detalhes])
		@assert conta.valor ≈ soma "conta $(conta.codigo): soma de detalhes ($soma) nao bate com valor ($(conta.valor))"
	end
end

CONTAS_VALIDAS = [
	"111000",
	"121000",
	"121100",
	"131000",
	"132000",
	"141000",
	"151000",
	"161000",
	"171000",
	"181000",
	"210000",
	"220000",
	"230000",
	"240000",
	"310000",
	"310100",
	"310101",
	"310102",
	"310103",
	"310104",
	"310105",
	"410100",
	"410101",
	"410200",
	"410201",
	"410202",
	"410300",
	"410301",
	"410302",
	"410400",
	"410401",
	"410402",
	"410500",
	"410501",
	"410502",
	"410503",
	"410504",
	"410600",
	"410601",
	"410602",
	"410603",
	"410604",
	"410700",
	"410701",
	"410702",
	"410703",
	"410704",
	"410800",
	"410801",
	"410802",
	"410900",
	"410901",
	"410904",
	"410907",
	"410908",
	"410909",
	"410910",
	"501000",
	"502000",
	"503000",
	"504000",
	"505000",
	"506000",
	"507000",
	"508000",
	"610000",
	"620000",
	"620100",
	"620200",
	"620300",
	"620400",
	"620500",
	"620501",
	"620502",
	"620503",
	"620504",
	"620505",
	"630000",
	"630100",
	"630200",
	"630300",
	"630400",
	"630500",
	"630501",
	"630502",
	"630503",
	"630504",
	"630505",
	"710000"
]

function assert_codigo_conta(conta::Conta)
	@assert conta.codigo in CONTAS_VALIDAS "conta invalida: $(conta.codigo)"
end

function assert_sinal(x::Union{Conta, DetalheConta})
	@assert x.valor >= -eps()
end


ELEMENTOS_DETALHES_CONTAS = Dict{String, Vector{DataType}}([
	"111000" => [Moeda; Posicao]
	"121000" => [Moeda; Posicao]
	"121100" => [Moeda; Posicao]
	"131000" => [Moeda; Posicao]
	"132000" => [Moeda; Posicao]
	"141000" => [Moeda; Posicao]
	"151000" => [Moeda; Posicao]
	"161000" => [Moeda; Posicao]
	"171000" => [Moeda; Posicao]
	"181000" => [Moeda; Posicao]
	"210000" => [Pais; Moeda]
	"220000" => [Pais; Moeda]
	"230000" => [Pais; Moeda]
	"240000" => [Pais; Moeda]
	"501000" => [Moeda]
	"502000" => [Moeda]
])

function assert_tem_detalhe(conta::Conta)
	codigo = conta.codigo
	if length(conta.detalhes) == 0
		@assert !haskey(ELEMENTOS_DETALHES_CONTAS, codigo) "conta $codigo deve ter detalhes dos tipos $(ELEMENTOS_DETALHES_CONTAS[codigo])"
	else
		for detalhe in conta.detalhes
			assert_elementos_detalhe(codigo, detalhe)
		end
	end

end

function assert_elementos_detalhe(codigo::String, detalhe::DetalheConta)
	gabarito = ELEMENTOS_DETALHES_CONTAS[codigo]
	tipos = [typeof(el) for el in detalhe.elementos]
	@assert length(tipos) == length(gabarito) "conta $codigo: $detalhe deveria ter $(length(gabarito)) ElementoDetalhe mas tem $(length(tipos))"
	for t in tipos
		@assert t in gabarito "conta $codigo: elemento detalhe invalido ($t)"
	end
end

FORMULAS = Dict{String, Function}([
	"310000" => d -> get_valor(d, "310100") * (get_valor(d, "310105")/100)
	"310100" => d -> get_valor(d, "310101", 0.0) + get_valor(d, "310102", 0.0) + get_valor(d, "310103", 0.0) + get_valor(d, "310104", 0.0)
	"410100" => d -> 100.0
	"410200" => d -> get_valor(d, "410201", 0.0) + get_valor(d, "410202", 0.0)
	"410300" => d -> get_valor(d, "410301", 0.0) + get_valor(d, "410302", 0.0)
	"410400" => d -> get_valor(d, "410401", 0.0) + get_valor(d, "410402", 0.0)
	"410500" => d -> get_valor(d, "410501", 0.0) + get_valor(d, "410502", 0.0) + get_valor(d, "410503", 0.0) + get_valor(d, "410504", 0.0)
	"410600" => d -> get_valor(d, "410601", 0.0) + get_valor(d, "410602", 0.0) + get_valor(d, "410603", 0.0) + get_valor(d, "410604", 0.0)
	"410700" => d -> get_valor(d, "410701", 0.0) + get_valor(d, "410702", 0.0) + get_valor(d, "410703", 0.0) + get_valor(d, "410704", 0.0)
	"410800" => d -> get_valor(d, "410801", 0.0) + get_valor(d, "410802", 0.0)
	"410900" => d -> get_valor(d, "410901", 0.0) + get_valor(d, "410904", 0.0) + get_valor(d, "410907", 0.0) + get_valor(d, "410908", 0.0) + get_valor(d, "410909", 0.0) + get_valor(d, "410910", 0.0)
	"503000" => d -> get_valor(d, "310000", 0.0) + get_valor(d, "410400", 0.0) + get_valor(d, "410500", 0.0) + get_valor(d, "410600", 0.0) + get_valor(d, "410700", 0.0) + get_valor(d, "410800", 0.0) + get_valor(d, "410900", 0.0)
	"620000" => d -> get_valor(d, "620200", 0.0) + get_valor(d, "620300", 0.0) + get_valor(d, "620400", 0.0) + get_valor(d, "620500", 0.0) - get_valor(d, "620100", 0.0)
	"620500" => d -> get_valor(d, "620502", 0.0) + get_valor(d, "620503", 0.0) + get_valor(d, "620504", 0.0) + get_valor(d, "620505", 0.0) - get_valor(d, "620501", 0.0)
	"630000" => d -> get_valor(d, "630200", 0.0) + get_valor(d, "630300", 0.0) + get_valor(d, "630400", 0.0) + get_valor(d, "630500", 0.0) - get_valor(d, "630100", 0.0)
	"630500" => d -> get_valor(d, "630502", 0.0) + get_valor(d, "630503", 0.0) + get_valor(d, "630504", 0.0) + get_valor(d, "630505", 0.0) - get_valor(d, "630501", 0.0)
	"710000" => d -> max(get_valor(d, "610000", 0.0) + get_valor(d, "505000", 0.0),  (get_valor(d, "504000")/100) * get_valor(d, "503000", 0.0))
])

function assert_formulas(doc::Doc2011)

	for (codigo, fun) in FORMULAS
		if has_conta(doc, codigo)
			stored = get_valor(doc, codigo)
			evaluated = fun(doc)
			@assert stored ≈ evaluated "conta $codigo: valor informado ($stored) nao bate com o valor da formula ($evaluated)"
		end
	end

end
