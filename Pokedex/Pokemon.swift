//
//  Pokemon.swift
//  Pokedex
//
//  Created by Kimar Arakaki Neves on 2016-12-04.
//  Copyright © 2016 Kimar. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionName: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLevel: String!
    private var _nextEvolutionTxt: String!
    
    private var _pokemonURL: String!
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    var description: String {
        if _description == nil{
            _description = ""
        }
        return _description
    }
    
    var type: String {
        if _type == nil{
            _type = ""
        }
        return _type
    }
    
    var defense: String {
        if _defense == nil{
            _defense = ""
        }
        return _defense
    }
    
    var height: String {
        if _height == nil{
            _height = ""
        }
        return _height
    }
    
    var weight: String {
        if _weight == nil{
            _weight = ""
        }
        return _weight
    }
    
    var attack: String {
        if _attack == nil{
            _attack = ""
        }
        return _attack
    }
    
    var nextEvolutionName: String {
        if _nextEvolutionName == nil{
            _nextEvolutionName = ""
        }
        return _nextEvolutionName
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionId == nil{
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var nextEvolutionLevel: String {
        if _nextEvolutionLevel == nil{
            _nextEvolutionLevel = ""
        }
        return _nextEvolutionLevel
    }
    
    var nextEvolutionTxt: String {
        if _nextEvolutionTxt == nil{
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    
    init(name: String, pokedexId: Int){
        self._name = name
        self._pokedexId = pokedexId
        
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
    }
    
    func donwloadPokemonDetails(completed: @escaping DownloadComplete){
        Alamofire.request(_pokemonURL).responseJSON { response in
            if let pokemonInfo = response.result.value as? Dictionary<String, AnyObject> {
                if let weight = pokemonInfo["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = pokemonInfo["height"] as? String {
                    self._height = height
                }
                
                if let attack = pokemonInfo["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                
                if let defense = pokemonInfo["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                
                if let types = pokemonInfo["types"] as? [Dictionary<String,String>], types.count > 0 {
                    if let name = types[0]["name"] {
                       self._type = "\(name.capitalized)"
                    }
                    
                    if types.count > 1 {
                        for x in 1..<types.count {
                            if let name = types[x]["name"] {
                                self._type! += "/\(name.capitalized)"
                            }
                        }
                    }
                }
                
                if let descArray = pokemonInfo["descriptions"] as? [Dictionary<String, String>] , descArray.count > 0 {
                    if let uri = descArray[0]["resource_uri"] {
                        let descriptionURL = "\(URL_BASE)\(uri)"
                        
                        Alamofire.request(descriptionURL).responseJSON { response in
                            if let descDetails = response.result.value as? Dictionary<String, AnyObject> {
                                if let description = descDetails["description"] as? String {
                                    let fixedDescription = description.replacingOccurrences(of: "POKMON", with: "Pokemon")
                                    
                                    self._description = fixedDescription
                                }
                            }
                            
                            completed()
                        }
                    }
                }
                
                if let evolutions = pokemonInfo["evolutions"] as? [Dictionary<String, AnyObject>] , evolutions.count > 0 {
                    if let nextEvo = evolutions[0]["to"] as? String {
                        if nextEvo.range(of: "mega") == nil {
                            self._nextEvolutionName = nextEvo
                        }
                    }
                    
                    if let uri = evolutions[0]["resource_uri"] as? String {
                        let evoIdEndPathURL = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                        let nextEvoId = evoIdEndPathURL.replacingOccurrences(of: "/", with: "")
                        
                        self._nextEvolutionId = nextEvoId
                    }
                    
                    if let lvl = evolutions[0]["level"] as? Int {
                        self._nextEvolutionLevel = "\(lvl)"
                    }
                    
                    if self.nextEvolutionId != "" {
                        self._nextEvolutionTxt = "Next Evolution: \(self.nextEvolutionName) - LVL \(self.nextEvolutionLevel)"
                    }
                }
            }
            
            completed()
        }
    }
}
