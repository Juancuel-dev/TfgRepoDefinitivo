package tfg.service;

import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.stereotype.Service;

import tfg.model.Game;
import tfg.repository.GamesRepository;

import java.util.List;

@Service
public class GamesServiceCmdImpl implements GamesServiceCmd{

    private final GamesRepository gamesRepository;

    // Constructor de inyección de dependencias
    public GamesServiceCmdImpl(GamesRepository gamesRepository) {
        this.gamesRepository = gamesRepository;
    }

    // Obtener todos los juegos
    public List<Game> findAll() {
        return gamesRepository.findAll();
    }

    // Buscar un juego por su ID
    public Game findById(String id) throws NotFoundException{
        return gamesRepository.findById(id)
                .orElseThrow(() -> new NotFoundException());
    }

    // Guardar un juego (crear o actualizar)
    public Game save(Game game) {
        return gamesRepository.save(game);
    }

    // Guardar un juego (crear o actualizar)
    public List<Game> saveAll(List<Game> games) {
        return gamesRepository.saveAll(games);
    }

    // Actualizar un juego
    public Game update(Game game) {
        // Buscar el juego por ID
        return gamesRepository.findById(game.getId())
                .map(buscado -> {
                    // Si el juego existe, actualizamos sus campos
                    buscado.setName(game.getName());
                    buscado.setDescription(game.getDescription());
                    buscado.setCreator(game.getCreator());
                    buscado.setPrecio(game.getPrecio());
                    buscado.setStock(game.getStock());
                    buscado.setMetacritic(game.getMetacritic());
                    return gamesRepository.save(buscado);
                })
                .orElseThrow(() -> new IllegalArgumentException("No se encontró el juego con el id " + game.getId()));
    }

    // Comprobar si un juego existe por su ID
    public boolean existsById(String id){
        return gamesRepository.existsById(id);
    }

    // Eliminar un juego por su ID
    public void deleteById(String id) throws NotFoundException {
        if (!gamesRepository.existsById(id)) {
            throw new NotFoundException();
        }
        gamesRepository.deleteById(id);
    }
}