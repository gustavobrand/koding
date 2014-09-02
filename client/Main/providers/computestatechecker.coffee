class ComputeStateChecker extends KDObject

  constructor:(options = {})->

    super
      interval : options.interval ? 5000

    @kloud           = KD.singletons.kontrol.getKite
      name           : "kloud"
      environment    : KD.config.environment

    @machines        = []
    @machineStatuses = {}
    @tickInProgress  = no
    @running         = no
    @timer           = null

    KD.singletons.windowController.addFocusListener (state)=>
      if state then @start() else @stop()

  start:->

    return  if @running
    @running = yes

    info "ComputeState checker started."

    @tick()
    @timer = KD.utils.repeat @getOption('interval'), @bound 'tick'


  stop:->

    return  unless @running
    @running = no

    info "ComputeState checker stopped."

    KD.utils.killWait @timer


  addMachine:(machine)->

    for m in @machines
      return  if machine.uid is m.uid

    @machines.push machine


  tick:->

    return  unless @machines.length
    return  if @tickInProgress
    @tickInProgress = yes

    {computeController} = KD.singletons

    @machines.forEach (machine)=>

      log "calling machne info csc....", machine._id

      call = @kloud.info { machineId: machine._id }

      .then (response)=>

        log "csc: info response:", response

        computeController.eventListener
          .triggerState machine, status : response.State

        unless machine.status.state is response.State
          computeController.triggerReviveFor machine._id

        @addMachine machine

      .timeout ComputeController.timeout

      .catch (err)=>

        # Ignore pending event errors but log others
        unless err?.code is "107"
          log "csc: info error happened:", err

        @addMachine machine

    @machines = []
    @tickInProgress = no
