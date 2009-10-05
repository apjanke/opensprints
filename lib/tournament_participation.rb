class TournamentParticipation
  include DataMapper::Resource
  property :id, Serial
  property :eliminated, Boolean

  belongs_to :obs_racer
  belongs_to :tournament

  def best_time
    best = RaceParticipation.first("race.tournament_id" => tournament.id,
                            :obs_racer_id => obs_racer.id,
                            :order => [:finish_time.asc]
    )
    best.finish_time if best
  end

  def rank
    standings = self.tournament.tournament_participations.sort_by{|tp|[tp.best_time||Infinity]}
    standings.index(self)+1
  end

  def losses
    (RaceParticipation.all(:obs_racer_id => self.obs_racer_id, "race.tournament_id" => self.tournament_id).select {|rp| rp.race.winner != rp }).length
  end

  def race_participations
    RaceParticipation.all("race.tournament_id" => tournament.id,
                          :obs_racer => obs_racer)
  end

  def eliminate
    self.update_attributes(:eliminated => true)
  end
end
