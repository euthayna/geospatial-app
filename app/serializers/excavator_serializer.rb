class ExcavatorSerializer
  def initialize(excavator)
    @excavator = excavator
  end

  def as_json(*)
    {
      id: @excavator.id,
      company_name: @excavator.company_name,
      address: @excavator.address,
      crew_on_site: @excavator.crew_on_site
    }
  end
end