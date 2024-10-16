class Sentimentomodelos {
   
  String id;
  String sentindo;
  String data;

  Sentimentomodelos({
    required this.id,
    required this.sentindo,
    required this.data 
    });

  Sentimentomodelos.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      sentindo = map["sentindo"],
      data = map["data"];
  
  Map<String, dynamic> toMap(){
    return{
      "id": id,
      "sentindo": sentindo,
      "data": data,
    };
  }
}