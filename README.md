# XML2011.jl

[![License][license-img]](LICENSE)
[![travis][travis-img]][travis-url]
[![codecov][codecov-img]][codecov-url]

[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square
[travis-img]: https://img.shields.io/travis/lucasprocessi/XML2011.jl/master.svg?logo=travis&label=Linux&style=flat-square
[travis-url]: https://travis-ci.org/lucasprocessi/XML2011.jl
[codecov-img]: https://img.shields.io/codecov/c/github/lucasprocessi/XML2011.jl/master.svg?label=codecov&style=flat-square
[codecov-url]: http://codecov.io/github/lucasprocessi/XML2011.jl?branch=master

A Julia package that implements **XML 2011 (DDR) document**, as required by Brazilian Central Bank (BACEN)

## Example

```julia
using XML2011

data = Date(2020,1,1)
cnpj = "12345"
tipo = XML2011.Inclusao()
responsavel = XML2011.Responsavel("Fulano", "555-1234", "fulano@banco.com")
c1 = XML2011.Conta("503000", 5.75)
c2 = XML2011.Conta(
    "121000",
    [
        XML2011.DetalheConta([XML2011.Moeda(:USD), XML2011.Posicao(:onshore)], 10.00),
        XML2011.DetalheConta([XML2011.Moeda(:EUR), XML2011.Posicao(:offshore)], 5.10)
    ]
)
c3 = XML2011.Conta("410400", 5.75)
c4 = XML2011.Conta("410401", 5.75)

doc = XML2011.Doc2011(data, cnpj, tipo, responsavel, [c1, c2, c3, c4])

# writes to file ddr.xml
XML2011.write_xml("ddr.xml", doc)
```

### Output file: "ddr.xml"

```xml
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
```
