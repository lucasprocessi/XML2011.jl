
using Test
using Dates
using Printf
using EzXML
using XML2011

##### TESTE UNITARIO COM MOCK DATA
 data = Date(2020,1,1)
 cnpj = "12345"
 tipo = XML2011.Inclusao()
 responsavel = XML2011.Responsavel("Fulano", "555-1234", "fulano@banco.com")
 c1 = XML2011.Conta("503000", 5.75)
 @test XML2011.get_valor(c1) == 5.75
 c2 = XML2011.Conta(
     "121000",
     [
         XML2011.DetalheConta([XML2011.Moeda(:USD), XML2011.Posicao(:onshore)], 10.00),
         XML2011.DetalheConta([XML2011.Moeda(:EUR), XML2011.Posicao(:offshore)], 5.10)
     ]
 )
 @test XML2011.get_valor(c2) == 15.10
 @test XML2011.get_valor(c2, [XML2011.Moeda(:USD), XML2011.Posicao(:onshore)]) == 10.00
 @test XML2011.get_valor(c2, [XML2011.Posicao(:offshore), XML2011.Moeda(:EUR)]) ==  5.10 # ordem inversa
 @test_throws ErrorException XML2011.get_valor(c2, [XML2011.Posicao(:offshore), XML2011.Moeda(:JPY)]) # inexiste

 c3 = XML2011.Conta("410400", 5.75)
 c4 = XML2011.Conta("410401", 5.75)
 doc = XML2011.Doc2011(data, cnpj, tipo, responsavel, [c1, c2, c3, c4])

 io = IOBuffer()
 XML2011.write_xml(io, doc)
 xml_written = String(take!(io))
 xml_test = """
 <?xml version="1.0" encoding="UTF-8"?>
 <documentoDDR cnpj="12345" dataBase="2020-01-01" codigoDocumento="2011" tipoEnvio="I">
   <parametros>
     <parametro codigoParametro="31" valorParametro="Fulano"/>
     <parametro codigoParametro="32" valorParametro="555-1234"/>
     <parametro codigoParametro="33" valorParametro="fulano@banco.com"/>
   </parametros>
   <contas>
     <conta codigoConta="503000" valorConta="5.75"/>
     <conta codigoConta="121000" valorConta="15.10">
       <detalhamentosDDR>
         <detalhamentoDDR valorDetalhe="10.00">
           <detalhe codigoElemento="83" valorElemento="USD"/>
           <detalhe codigoElemento="84" valorElemento="1"/>
         </detalhamentoDDR>
         <detalhamentoDDR valorDetalhe="5.10">
           <detalhe codigoElemento="83" valorElemento="EUR"/>
           <detalhe codigoElemento="84" valorElemento="2"/>
         </detalhamentoDDR>
       </detalhamentosDDR>
     </conta>
     <conta codigoConta="410400" valorConta="5.75"/>
     <conta codigoConta="410401" valorConta="5.75"/>
   </contas>
 </documentoDDR>
 """

 function is_equal(x1::EzXML.Document, x2::EzXML.Document)

     function get_parsed_string(x::EzXML.Document)
         b = IOBuffer()
         prettyprint(b, x)
         return String(take!(b))
     end

     s1 = get_parsed_string(x1)
     s2 = get_parsed_string(x2)

     return s1 == s2

 end

 @test is_equal(parsexml(xml_test), parsexml(xml_written))


#### TESTES READ
# Parse String
doc_read1 = XML2011.parse_xml(xml_test)

# Read File
file = "ddr.xml"
XML2011.write_xml(file, doc_read1)
doc_read2 = XML2011.read_xml(file)
rm(file)

# Comparar
b1 = IOBuffer(); XML2011.write_xml(b1, doc_read1); s1 = String(take!(b1))
b2 = IOBuffer(); XML2011.write_xml(b2, doc_read2); s2 = String(take!(b2))
@test s1 == s2


 #### TESTES GENERICOS
 @test XML2011.Moeda(:USD) == XML2011.Moeda(:USD)
 @test XML2011.Moeda(:USD) != XML2011.Moeda(:EUR)
 @test XML2011.Moeda(:USD) != XML2011.Posicao(:onshore)


## Validacao de formula
# "310000" => doc -> get_valor(doc, "310100") * (get_valor(doc, "310105")/100)
v = Vector{XML2011.Conta}()
c1 = XML2011.Conta("310100", 1000.0)
c2 = XML2011.Conta("310105", 90.0)
c3 = XML2011.Conta("310000", 1000.0 * (90/100))
c3_wrong = XML2011.Conta("310000", 1000.0 * (89/100))
c4 = XML2011.Conta("310101", 700.0)
c5 = XML2011.Conta("310104", 300.0)

doc = XML2011.Doc2011(data, cnpj, tipo, responsavel, [c1, c2, c3, c4, c5])

@test_throws AssertionError XML2011.Doc2011(data, cnpj, tipo, responsavel, [c1, c2, c3_wrong, c4, c5])
